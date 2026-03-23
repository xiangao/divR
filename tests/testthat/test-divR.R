test_that("divR returns correct class and fields", {
  skip_if_no_torch()

  set.seed(42)
  n <- 50
  Z <- matrix(rnorm(n), ncol = 1)
  X <- Z + rnorm(n)
  Y <- X + rnorm(n)

  res <- divR::divR(Z = Z, X = matrix(X, ncol = 1), Y = matrix(Y, ncol = 1),
              num_epochs = 5, silent = TRUE)

  expect_s3_class(res, "divR")
  expect_true(is.function(res$DIV_f))
  expect_true(is.function(res$DIV_g))
  expect_true(is.matrix(res$loss_vec))
  expect_equal(nrow(res$loss_vec), 5)

  # Check stored fields
  expect_true(!is.null(res$Z))
  expect_true(!is.null(res$X))
  expect_true(!is.null(res$Y))
  expect_equal(res$hidden_dim, 100)
  expect_equal(res$num_layer, 3)
  expect_equal(res$num_epochs, 5)
  expect_true(res$standardize)
})

test_that("divR validates inputs", {
  Z <- matrix(1:10, ncol = 1)
  X <- matrix(1:10, ncol = 1)
  Y <- matrix(1:5, ncol = 1)

  expect_error(divR::divR(Z = Z, X = X, Y = Y, num_epochs = 1, silent = TRUE),
               "Sample size should be same")

  expect_error(divR::divR(Z = matrix(1, ncol = 1), X = matrix(1, ncol = 1),
                    Y = matrix(1, ncol = 1), num_epochs = 1, silent = TRUE),
               "Sample size should be greater than 1")
})

test_that("divR warns about constant variables", {
  skip_if_no_torch()

  set.seed(42)
  n <- 50
  Z <- matrix(rep(1, n), ncol = 1)  # constant
  X <- matrix(rnorm(n), ncol = 1)
  Y <- matrix(rnorm(n), ncol = 1)

  expect_warning(
    divR::divR(Z = Z, X = X, Y = Y, num_epochs = 2, silent = TRUE),
    "constant on training data"
  )
})

test_that("divR with W validates sample size", {
  Z <- matrix(1:10, ncol = 1)
  X <- matrix(1:10, ncol = 1)
  Y <- matrix(1:10, ncol = 1)
  W <- matrix(1:5, ncol = 1)

  expect_error(divR::divR(Z = Z, X = X, Y = Y, W = W, num_epochs = 1, silent = TRUE),
               "Sample size of W must match")
})
