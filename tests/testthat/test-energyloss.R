test_that("energyloss returns correct structure", {
  skip_if_no_torch()

  x0 <- torch::torch_randn(10, 2)
  x <- torch::torch_randn(10, 2)
  xp <- torch::torch_randn(10, 2)

  res <- divR:::energyloss(x0 = x0, x = x, xp = xp, verbose = TRUE)
  expect_length(res, 3)
  expect_true(inherits(res[[1]], "torch_tensor"))
})

test_that("energyloss non-verbose returns single tensor", {
  skip_if_no_torch()

  x0 <- torch::torch_randn(10, 2)
  x <- torch::torch_randn(10, 2)
  xp <- torch::torch_randn(10, 2)

  res <- divR:::energyloss(x0 = x0, x = x, xp = xp, verbose = FALSE)
  expect_true(inherits(res, "torch_tensor"))
})
