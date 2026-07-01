# Energy Loss Calculation with Beta Scaling

This function calculates the energy loss for given tensors. The loss is
calculated as the mean of the L2 norms between \`x0\` and \`x\` and
between \`x0\` and \`xp\`, each raised to the power of \`beta\`,
subtracted by half the mean of the L2 norm between \`x\` and \`xp\`,
also raised to the power of \`beta\`.

## Usage

``` r
energylossbeta(x0, x, xp, beta, verbose = FALSE)
```

## Arguments

- x0:

  A tensor representing the target values.

- x:

  A tensor representing the model's stochastic predictions.

- xp:

  A tensor representing another draw of the model's stochastic
  predictions.

- beta:

  A numeric value for scaling the energy loss.

- verbose:

  A boolean indicating whether to return prediction loss s1 =
  E(\|\|x0-x\|\|) and variance loss s2 = E(\|\|x-xp\|\|).

## Value

A scalar representing the calculated energy loss.
