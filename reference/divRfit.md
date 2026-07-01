# Distributional IV Model Fit Function

This function fits a joint distributional IV model to the provided data.
It allows for the tuning of several parameters related to model
complexity and model training.

## Usage

``` r
divRfit(
  Z,
  X,
  Y,
  W,
  epsx_dim = 50,
  epsy_dim = 50,
  epsh_dim = 50,
  hidden_dim = 100,
  num_layer = 3,
  num_epochs = 1000,
  lr = 10^(-3),
  beta = 1,
  silent = FALSE
)
```

## Arguments

- Z:

  A data frame, matrix, vector, or factor variable representing the
  instrumental variable.

- X:

  A data frame, matrix, vector, or factor variable representing the
  predictor.

- Y:

  A data frame, matrix, vector, or factor variable representing the
  target variable.

- W:

  (Optional) A data frame, matrix, vector, or factor variable
  representing the exogenous variable(s).

- epsx_dim:

  The dimension of the noise corresponding to the predictor introduced
  in the model (default: 50).

- epsy_dim:

  The dimension of the noise corresponding to the outcome introduced in
  the model (default: 50).

- epsh_dim:

  The dimension of the noise corresponding to the hidden confounder
  introduced in the model (default: 50).

- hidden_dim:

  The size of the hidden layer in the model (default: 100).

- num_layer:

  The number of layers in the model (default: 3).

- num_epochs:

  The number of epochs to be used in training (default: 1000).

- lr:

  The learning rate to be used in training (default: 10^-3).

- beta:

  The beta scaling factor for energy loss, numeric value from (0,2)
  (default: 1).

- silent:

  A boolean indicating whether to suppress output during model training
  (default: FALSE).

## Value

A list containing the trained DIV model and a matrix of loss values.
