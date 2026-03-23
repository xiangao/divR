#' Energy Loss Calculation
#'
#' This function calculates the energy loss for given tensors. The loss is calculated
#' as the mean of the L2 norms between `x0` and `x` and between `x0` and `xp`,
#' subtracted by half the mean of the L2 norm between `x` and `xp`.
#'
#' @param x0 A tensor representing the target values.
#' @param x A tensor representing the model's stochastic predictions.
#' @param xp A tensor representing another draw of the model's stochastic predictions.
#' @param verbose A boolean indicating whether to return prediction loss s1 = E(||x0-x||) and variance loss s2 = E(||x-xp||).
#'
#' @return A vector containing the calculated energy loss, `s1`, and `s2`, or a scalar representing the calculated energy loss.
#'
#' @keywords internal
#'
energyloss <- function(x0, x, xp, verbose = FALSE) {
  if (!requireNamespace("torch", quietly = TRUE)) {
    stop("This function requires the 'torch' package. Install it with install.packages('torch').", call. = FALSE)
  }

  s1 <- torch::torch_mean(torch::torch_norm(x - x0, 2, dim = 2)) / 2 +
    torch::torch_mean(torch::torch_norm(xp - x0, 2, dim = 2)) / 2
  s2 <- torch::torch_mean(torch::torch_norm(x - xp, 2, dim = 2))

  if (isTRUE(verbose)) {
    return(c((s1 - s2 / 2), s1, s2))
  } else {
    return(s1 - s2 / 2)
  }
}
