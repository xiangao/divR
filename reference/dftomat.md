# Convert Data Frame to Numeric Matrix

This function converts a data frame into a numeric matrix. If the data
frame contains factor variables, they are first converted to dummy
variables (one-hot encoding). If the data frame contains character
variables, they are first converted to factors and then to dummy
variables.

## Usage

``` r
dftomat(df)
```

## Arguments

- df:

  A data frame to be converted to a numeric matrix.

## Value

A numeric matrix corresponding to the input data frame.
