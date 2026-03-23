#' Print Function for a divR Model Object
#'
#' This function displays a summary of a fitted divR model object.
#'
#' @param x A trained divR model returned from \code{\link{divR}}.
#' @param ... additional arguments (currently ignored).
#'
#' @return Invisibly returns the input object. Prints a summary of the model
#' architecture, training process, and loss values.
#'
#' @export
print.divR <- function(x, ...) {
  cat("\ndivR object with ")

  cat("\n \t  noise dimensions (for shared noise eps_H, and for indep. noise eps_X and eps_Y): ",
      "(", x$epsh_dim, ",", x$epsx_dim, ",", x$epsy_dim, ")", sep = "")
  cat("\n \t  hidden dimensions: ", x$hidden_dim)
  cat("\n \t  number of layers: ", x$num_layer)
  cat("\n \t  number of epochs: ", x$num_epochs)
  cat("\n \t  learning rate: ", x$lr)
  cat("\n \t  standardization: ", x$standardize)

  m <- nrow(x$loss_vec)
  print_at <- pmax(1, floor(seq(1, m, length = 11)))
  pr <- cbind(print_at, x$loss_vec[print_at, ])
  colnames(pr) <- c("epoch", colnames(x$loss_vec))
  cat("\nTraining loss: \n")
  print(as.data.frame(pr), row.names = FALSE)
  cat("\nPrediction-loss E(||U-Uhat||) and variance-loss E(||Uhat-Uhat'||) should ideally be equally large --\nconsider training for more epochs if there is a mismatch.\n\n")

  invisible(x)
}
