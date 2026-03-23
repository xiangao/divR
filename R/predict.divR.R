#' Prediction Function for a divR Model Object
#'
#' This function computes predictions from a trained divR model. It allows for estimation
#' of the interventional mean and quantiles, as well as sampling from the fitted interventional distribution.
#'
#' @param object A trained divR model returned from \code{\link{divR}}.
#' @param Xtest A matrix or data frame representing predictors in the test set.
#' @param Wtest A matrix or data frame representing exogenous predictors in the test set.
#' @param type The type of prediction to make: "mean", "sample", or "quantile".
#' @param trim The proportion of extreme values to trim when calculating the mean (default: 0.05).
#' @param quantiles The quantiles to estimate if type is "quantile" (default: 0.1*(1:9)).
#' @param nsample The number of samples to draw (default: 200).
#' @param drop A boolean indicating whether to drop dimensions of length 1 from the output (default: TRUE).
#' @param ... additional arguments (currently ignored).
#' @return A vector or matrix/array of predictions.
#'
#' @importFrom stats quantile sd
#' @export
predict.divR <- function(object, Xtest, Wtest = NULL,
                         type = c("mean", "sample", "quantile")[1],
                         trim = 0.05, quantiles = 0.1 * (1:9),
                         nsample = 200, drop = TRUE, ...) {

  # torch guard at call time
  if (!requireNamespace("torch", quietly = TRUE)) {
    stop("This function requires the 'torch' package. Install it with install.packages('torch').", call. = FALSE)
  }
  if (isFALSE(get("torch_is_installed", asNamespace("torch"))())) {
    stop("Torch backend not installed on this machine. Run torch::install_torch() locally.", call. = FALSE)
  }

  if (!(type %in% c("mean", "sample", "quantile"))) {
    stop("Type must be one of 'mean', 'sample', or 'quantile'.")
  }

  device <- use_device()

  # Validate input
  assert_numeric(trim, lower = 0, upper = 0.5)
  assert_count(nsample)
  assert_numeric(quantiles, lower = 0, upper = 1)
  assert_logical(drop)
  Xtest <- check_input(Xtest)
  if (!is.null(Wtest)) Wtest <- check_input(Wtest)

  if (ncol(object$X) != ncol(Xtest)) {
    stop("'Xtest' should contain the same number of variables as used for training.")
  }
  if (!is.null(object$W) && is.null(Wtest)) {
    stop("Exogenous predictors W were used during training. Provide Wtest for conditional prediction.")
  }
  if (!is.null(Wtest) && ncol(object$W) != ncol(Wtest)) {
    stop("'Wtest' should contain the same number of variables as used for training.")
  }
  if (!is.null(Wtest) && nrow(Wtest) != nrow(Xtest)) {
    stop("'Xtest' and 'Wtest' should have the same number of rows.")
  }

  # Move to tensors
  Xtest_t <- torch::torch_tensor(Xtest, device = device)
  if (!is.null(Wtest)) Wtest_t <- torch::torch_tensor(Wtest, device = device)

  # Standardize if needed
  if (isTRUE(object$standardize)) {
    Xtest_t <- (Xtest_t - torch::torch_tensor(object$muX, device = device)) /
      torch::torch_tensor(object$sddX, device = device)
    if (!is.null(Wtest)) {
      Wtest_t <- (Wtest_t - torch::torch_tensor(object$muW, device = device)) /
        torch::torch_tensor(object$sddW, device = device)
    }
  }

  # Generate predictions
  if (!is.null(Wtest)) {
    Yhat1 <- object$DIV_f(x = Xtest_t, w = Wtest_t)
    Yhat <- array(dim = c(dim(Yhat1)[1], dim(Yhat1)[2], nsample))
    for (sam in 1:nsample) {
      pred <- object$DIV_f(x = Xtest_t, w = Wtest_t)
      if (isTRUE(object$standardize)) {
        pred <- sweep(sweep(pred, 2, object$sddY, FUN = "*"), 2, object$muY, FUN = "+")
      }
      Yhat[, , sam] <- pred
    }
  } else {
    Yhat1 <- object$DIV_f(x = Xtest_t)
    Yhat <- array(dim = c(dim(Yhat1)[1], dim(Yhat1)[2], nsample))
    for (sam in 1:nsample) {
      pred <- object$DIV_f(x = Xtest_t)
      if (isTRUE(object$standardize)) {
        pred <- sweep(sweep(pred, 2, object$sddY, FUN = "*"), 2, object$muY, FUN = "+")
      }
      Yhat[, , sam] <- pred
    }
  }

  process_output(Yhat, type, quantiles, trim, drop)
}

# Helper used inside predict.divR
process_output <- function(Yhat, type, quantiles, trim, drop) {
  if (type == "sample") {
    dimnames(Yhat)[[3]] <- paste0("sample_", seq_len(dim(Yhat)[3]))
    return(if (drop) drop(Yhat) else Yhat)
  }
  if (type == "mean") {
    return(if (drop) drop(apply(Yhat, 1:(length(dim(Yhat)) - 1), mean, trim = trim))
           else apply(Yhat, 1:(length(dim(Yhat)) - 1), mean, trim = trim))
  }
  if (type == "quantile") {
    if (length(quantiles) == 1) {
      return(if (drop) drop(apply(Yhat, 1:(length(dim(Yhat)) - 1), stats::quantile, quantiles))
             else apply(Yhat, 1:(length(dim(Yhat)) - 1), stats::quantile, quantiles))
    } else {
      return(
        if (drop) {
          drop(aperm(apply(Yhat, 1:(length(dim(Yhat)) - 1), stats::quantile, quantiles), c(2, 3, 1)))
        } else {
          aperm(apply(Yhat, 1:(length(dim(Yhat)) - 1), stats::quantile, quantiles), c(2, 3, 1))
        }
      )
    }
  }
}
