test_that("predict.divR returns correct dimensions for mean", {
  skip_if_no_torch()

  set.seed(42)
  n <- 50
  Z <- matrix(rnorm(n), ncol = 1)
  X <- matrix(Z + rnorm(n), ncol = 1)
  Y <- matrix(X + rnorm(n), ncol = 1)

  res <- divR::divR(Z = Z, X = X, Y = Y, num_epochs = 5, silent = TRUE)

  Xtest <- matrix(seq(-2, 2, length.out = 10), ncol = 1)
  pred <- predict(res, Xtest = Xtest, type = "mean", nsample = 10)
  expect_equal(length(pred), 10)
})

test_that("predict.divR returns correct dimensions for sample", {
  skip_if_no_torch()

  set.seed(42)
  n <- 50
  Z <- matrix(rnorm(n), ncol = 1)
  X <- matrix(Z + rnorm(n), ncol = 1)
  Y <- matrix(X + rnorm(n), ncol = 1)

  res <- divR::divR(Z = Z, X = X, Y = Y, num_epochs = 5, silent = TRUE)

  Xtest <- matrix(seq(-2, 2, length.out = 10), ncol = 1)
  pred <- predict(res, Xtest = Xtest, type = "sample", nsample = 5)
  expect_equal(length(pred), 10 * 5)  # dropped to vector for univariate Y
})

test_that("predict.divR returns correct dimensions for quantile", {
  skip_if_no_torch()

  set.seed(42)
  n <- 50
  Z <- matrix(rnorm(n), ncol = 1)
  X <- matrix(Z + rnorm(n), ncol = 1)
  Y <- matrix(X + rnorm(n), ncol = 1)

  res <- divR::divR(Z = Z, X = X, Y = Y, num_epochs = 5, silent = TRUE)

  Xtest <- matrix(seq(-2, 2, length.out = 10), ncol = 1)
  pred <- predict(res, Xtest = Xtest, type = "quantile",
                  quantiles = c(0.1, 0.5, 0.9), nsample = 10)
  expect_equal(nrow(pred), 10)
  expect_equal(ncol(pred), 3)
})

test_that("predict.divR validates Xtest dimensions", {
  skip_if_no_torch()

  set.seed(42)
  n <- 50
  Z <- matrix(rnorm(n * 2), ncol = 2)
  X <- matrix(rnorm(n * 2), ncol = 2)
  Y <- matrix(rnorm(n), ncol = 1)

  res <- divR::divR(Z = Z, X = X, Y = Y, num_epochs = 5, silent = TRUE)

  Xtest_wrong <- matrix(rnorm(10), ncol = 1)  # 1 col, should be 2
  expect_error(predict(res, Xtest = Xtest_wrong), "same number of variables")
})
