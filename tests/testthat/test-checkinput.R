test_that("check_input converts vectors to matrix", {
  res <- divR:::check_input(1:5)
  expect_true(is.matrix(res))
  expect_equal(ncol(res), 1)
  expect_equal(nrow(res), 5)
})

test_that("check_input converts factors via one-hot encoding", {
  res <- divR:::check_input(factor(c("a", "b", "a", "c")))
  expect_true(is.matrix(res))
  expect_true(ncol(res) >= 1)
})

test_that("check_input passes through matrices", {
  m <- matrix(1:6, ncol = 2)
  res <- divR:::check_input(m)
  expect_equal(res, m)
})
