test_that("print.divR runs without error", {
  skip_if_no_torch()

  set.seed(42)
  n <- 50
  Z <- matrix(rnorm(n), ncol = 1)
  X <- matrix(Z + rnorm(n), ncol = 1)
  Y <- matrix(X + rnorm(n), ncol = 1)

  res <- divR::divR(Z = Z, X = X, Y = Y, num_epochs = 5, silent = TRUE)
  expect_output(print(res), "divR object with")
  expect_output(print(res), "noise dimensions")
  expect_output(print(res), "Training loss")
})
