# Define a Stochastic Generative Neural Network Model with Noise at Input Layer

This function defines a generative neural network model for a certain
architecture and adds noise to the input layer.

## Usage

``` r
nn_model(in_dim, noise_dim, hidden_dim = 100, out_dim, num_layer = 3)
```

## Arguments

- in_dim:

  Integer. Input dimension.

- noise_dim:

  Integer. Dimension of the noise to inject.

- hidden_dim:

  Integer. Number of neurons in the hidden layers (default: 100).

- out_dim:

  Integer. Output dimension.

- num_layer:

  Integer. Number of layers in the model (default: 3).

## Value

A generative neural network model with intermediate noise injection.
