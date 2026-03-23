#' Distributional IV Model Fit Function
#'
#' This function fits a joint distributional IV model to the provided data. It allows for the tuning of
#' several parameters related to model complexity and model training.
#'
#' @inheritParams divR
#' @return A list containing the trained DIV model and a matrix of loss values.
#' @keywords internal
divRfit <- function(Z, X, Y, W,
                   epsx_dim = 50, epsy_dim = 50, epsh_dim = 50,
                   hidden_dim = 100, num_layer = 3,
                   num_epochs = 1000, lr = 10^(-3), beta = 1, silent = FALSE) {

  # Load guard
  if (!requireNamespace("torch", quietly = TRUE)) {
    stop("This function requires the 'torch' package. Install it with install.packages('torch').", call. = FALSE)
  }
  if (isTRUE(utils::packageVersion("torch") >= "0.10.0")) {
    if (isFALSE(get("torch_is_installed", asNamespace("torch"))())) {
      stop("Torch backend not installed on this machine. Run torch::install_torch() locally.", call. = FALSE)
    }
  }

  # Determine device
  device <- use_device()

  # Input checks
  assert_count(epsh_dim)
  assert_count(epsx_dim)
  assert_count(epsy_dim)
  assert_count(hidden_dim)
  assert_count(num_layer)
  assert_count(num_epochs)
  assert_numeric(lr, len = 1, any.missing = FALSE, lower = 0)
  assert_logical(silent)
  assert_numeric(beta, lower = 0.01, upper = 1.99)

  # Dimensions
  in_dim_g <- dim(Z)[2] + ifelse(is.null(W), 0, dim(W)[2])
  out_dim_g <- dim(X)[2]
  in_dim_f <- dim(X)[2] + ifelse(is.null(W), 0, dim(W)[2])
  out_dim_f <- dim(Y)[2]

  noise_g_dim <- epsx_dim + epsh_dim
  noise_f_dim <- epsy_dim + epsh_dim

  # Generators
  gen_g <- nn_model(in_dim = in_dim_g, noise_dim = noise_g_dim,
                    hidden_dim = hidden_dim, out_dim = out_dim_g, num_layer = num_layer)
  gen_g$to(device = device)
  gen_g$train()

  gen_f <- nn_model(in_dim = in_dim_f, noise_dim = noise_f_dim,
                    hidden_dim = hidden_dim, out_dim = out_dim_f, num_layer = num_layer)
  gen_f$to(device = device)
  gen_f$train()

  # Optimizer
  params <- c(gen_g$parameters, gen_f$parameters)
  optim_gen <- torch::optim_adam(params, lr = lr)

  # Tensors
  Z <- torch::torch_tensor(Z, device = device)
  X <- torch::torch_tensor(X, device = device)
  Y <- torch::torch_tensor(Y, device = device)
  if (!is.null(W)) { W <- torch::torch_tensor(W, device = device) }

  x0_in_loss <- torch::torch_cat(list(X, Y), dim = 2)$to(device = device)
  n <- dim(X)[1]

  loss_vec <- matrix(nrow = num_epochs, ncol = 3)
  colnames(loss_vec) <- c("Energy loss", "E(||U-Uhat||)", "E(||Uhat-Uhat'||)")
  print_at <- pmax(1, floor(seq(1, num_epochs, length = 11)))

  # Training loop
  for (epoch in 1:num_epochs) {
    optim_gen$zero_grad()

    # Gaussian noise
    eps_x1 <- torch::torch_randn(n, epsx_dim)$to(device = device)
    eps_y1 <- torch::torch_randn(n, epsy_dim)$to(device = device)
    eps_h1 <- torch::torch_randn(n, epsh_dim)$to(device = device)

    eps_x2 <- torch::torch_randn(n, epsx_dim)$to(device = device)
    eps_y2 <- torch::torch_randn(n, epsy_dim)$to(device = device)
    eps_h2 <- torch::torch_randn(n, epsh_dim)$to(device = device)

    # Inputs for g: [Z, eps_x, eps_h, (W)]
    in_g1 <- torch::torch_cat(list(Z$to(device = device), eps_x1, eps_h1), dim = 2)
    in_g2 <- torch::torch_cat(list(Z$to(device = device), eps_x2, eps_h2), dim = 2)
    if (!is.null(W)) {
      in_g1 <- torch::torch_cat(list(in_g1, W), dim = 2)
      in_g2 <- torch::torch_cat(list(in_g2, W), dim = 2)
    }

    # g forward
    gen_X1 <- gen_g(in_g1)
    gen_X2 <- gen_g(in_g2)

    # Inputs for f: [X, eps_y, eps_h, (W)]
    in_f1 <- torch::torch_cat(list(gen_X1, eps_y1, eps_h1), dim = 2)
    in_f2 <- torch::torch_cat(list(gen_X2, eps_y2, eps_h2), dim = 2)
    if (!is.null(W)) {
      in_f1 <- torch::torch_cat(list(in_f1, W), dim = 2)
      in_f2 <- torch::torch_cat(list(in_f2, W), dim = 2)
    }

    # f forward
    gen_Y1 <- gen_f(in_f1)
    gen_Y2 <- gen_f(in_f2)

    gen_XY1 <- torch::torch_cat(list(gen_X1, gen_Y1), dim = 2)
    gen_XY2 <- torch::torch_cat(list(gen_X2, gen_Y2), dim = 2)

    # Loss
    if (beta == 1) {
      loss_fct <- energyloss(x0 = x0_in_loss, x = gen_XY1, xp = gen_XY2, verbose = TRUE)
    } else {
      loss_fct <- energylossbeta(x0 = x0_in_loss, x = gen_XY1, xp = gen_XY2,
                                 beta = beta, verbose = TRUE)
    }

    loss_vec[epoch, ] <- signif(c(sapply(loss_fct, as.numeric)), 3)

    loss_fct[[1]]$backward()
    optim_gen$step()

    if (!silent) {
      cat("\r ", round(100 * epoch / num_epochs), "% complete, epoch: ", epoch)
      if (epoch %in% print_at) {
        cat("\n")
        print(loss_vec[epoch, ])
      }
    }
  }

  gen_f$eval()
  gen_g$eval()

  # Interventional predictor: E[Y | do(X), W]
  # Input order must match training: [X, eps_y, eps_h, (W)]
  DIV_f <- function(x, w = NULL) {
    noise_y <- torch::torch_randn(nrow(x), epsy_dim)$to(device = device)
    noise_h <- torch::torch_randn(nrow(x), epsh_dim)$to(device = device)
    if (!is.null(W)) {
      input_f <- torch::torch_cat(list(x$to(device = device), noise_y, noise_h,
                                       w$to(device = device)), dim = 2)
    } else {
      input_f <- torch::torch_cat(list(x$to(device = device), noise_y, noise_h), dim = 2)
    }
    return(as.matrix(gen_f(input_f), ncol = out_dim_f))
  }

  # Predictive predictor: E[X, Y | Z, W]
  # Input order must match training: [Z, eps_x, eps_h, (W)]
  DIV_g <- function(z, w = NULL) {
    noise_x <- torch::torch_randn(nrow(z), epsx_dim)$to(device = device)
    noise_h <- torch::torch_randn(nrow(z), epsh_dim)$to(device = device)
    if (!is.null(W)) {
      input_g <- torch::torch_cat(list(z$to(device = device), noise_x, noise_h,
                                       w$to(device = device)), dim = 2)
    } else {
      input_g <- torch::torch_cat(list(z$to(device = device), noise_x, noise_h), dim = 2)
    }
    return(as.matrix(gen_g(input_g), ncol = out_dim_g))
  }

  list(DIV_f = DIV_f, DIV_g = DIV_g, loss_vec = loss_vec)
}
