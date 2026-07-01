# Print Function for a divR Model Object

This function displays a summary of a fitted divR model object.

## Usage

``` r
# S3 method for class 'divR'
print(x, ...)
```

## Arguments

- x:

  A trained divR model returned from
  [`divR`](https://xiangao.github.io/divR/reference/divR.md).

- ...:

  additional arguments (currently ignored).

## Value

Invisibly returns the input object. Prints a summary of the model
architecture, training process, and loss values.
