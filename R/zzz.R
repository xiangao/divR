.onAttach <- function(libname, pkgname) {
  if (!requireNamespace("torch", quietly = TRUE)) {
    packageStartupMessage(
      "The 'torch' package is suggested but not installed.\n",
      "Install it with: install.packages('torch')",
      "\nAfter installation, run torch::install_torch() if prompted."
    )
  }
}
