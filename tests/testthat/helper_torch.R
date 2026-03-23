skip_if_no_torch <- function() {
  if (!requireNamespace("torch", quietly = TRUE)) {
    skip("torch package not installed")
  }
  if (isTRUE(utils::packageVersion("torch") >= "0.10.0")) {
    if (isFALSE(get("torch_is_installed", asNamespace("torch"))())) {
      skip("torch backend not installed")
    }
  }
}
