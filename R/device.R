#' Determine Device for Torch Computations
#'
#' This function selects the most appropriate device (e.g., CUDA, MPS, or CPU)
#' for Torch computations based on system availability.
#'
#' @keywords internal
#' @noRd
use_device <- function() {
  if (!requireNamespace("torch", quietly = TRUE)) {
    packageStartupMessage("The 'torch' package is not installed. Defaulting to CPU. Install it with install.packages('torch').")
    return("cpu")
  }

  if (!torch::torch_is_installed()) {
    packageStartupMessage("Torch runtime is missing. Please install it with torch::install_torch(). Defaulting to CPU.")
    return("cpu")
  }

  if (torch::cuda_is_available()) {
    return(torch::torch_device("cuda"))
  }
  if (torch::backends_mps_is_available()) {
    return(torch::torch_device("mps"))
  }

  torch::torch_device("cpu")
}
