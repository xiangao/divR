# Prediction Function for a divR Model Object

This function computes predictions from a trained divR model. It allows
for estimation of the interventional mean and quantiles, as well as
sampling from the fitted interventional distribution.

## Usage

``` r
# S3 method for class 'divR'
predict(
  object,
  Xtest,
  Wtest = NULL,
  type = c("mean", "sample", "quantile")[1],
  trim = 0.05,
  quantiles = 0.1 * (1:9),
  nsample = 200,
  drop = TRUE,
  ...
)
```

## Arguments

- object:

  A trained divR model returned from
  [`divR`](https://xiangao.github.io/divR/reference/divR.md).

- Xtest:

  A matrix or data frame representing predictors in the test set.

- Wtest:

  A matrix or data frame representing exogenous predictors in the test
  set.

- type:

  The type of prediction to make: "mean", "sample", or "quantile".

- trim:

  The proportion of extreme values to trim when calculating the mean
  (default: 0.05).

- quantiles:

  The quantiles to estimate if type is "quantile" (default: 0.1\*(1:9)).

- nsample:

  The number of samples to draw (default: 200).

- drop:

  A boolean indicating whether to drop dimensions of length 1 from the
  output (default: TRUE).

- ...:

  additional arguments (currently ignored).

## Value

A vector or matrix/array of predictions.
