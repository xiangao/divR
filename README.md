# divR

Distributional Instrumental Variable Regression in R.

## Overview

divR implements the Distributional Instrumental Variable (DIV) method from Holovchak, Saengkyongam, Meinshausen & Shen (2025). DIV uses energy score-based generative modelling to estimate the full interventional distribution P(Y|do(X)) in the presence of unmeasured confounding, yielding interventional means, quantiles, and samples.

The package is based on the [DistributionIV](https://cran.r-project.org/package=DistributionIV) CRAN package by the same authors, with additional vignettes reproducing the paper's simulation studies and real-data applications.

## Installation

```r
# Install dependencies
install.packages(c("checkmate", "torch"))
torch::install_torch()

# Install divR
remotes::install_github("xiangao/divR")
```

## Usage

```r
library(divR)

# Simulate data with hidden confounding
set.seed(42)
n <- 1000
H <- rnorm(n)
Z <- matrix(rnorm(n), ncol = 1)
X <- matrix(Z + H + rnorm(n), ncol = 1)
Y <- matrix(2 * X + H + rnorm(n), ncol = 1)

# Fit DIV model
model <- divR(Z = Z, X = X, Y = Y, num_epochs = 500, silent = TRUE)
print(model)

# Interventional prediction E[Y | do(X)]
Xtest <- matrix(seq(-3, 3, length.out = 100), ncol = 1)
pred_mean <- predict(model, Xtest = Xtest, type = "mean")
pred_q <- predict(model, Xtest = Xtest, type = "quantile", quantiles = c(0.1, 0.5, 0.9))
pred_s <- predict(model, Xtest = Xtest, type = "sample", nsample = 100)
```

## Vignettes

### Simulation Studies (Paper Sections 3 & 6)

- [Section 3.3: Softplus Example](vignettes/Section3_3.Rmd) — Toy motivating example
- [Section 6.1: Sinusoidal DGP](vignettes/Section6_1.Rmd) — Nonlinear treatment effect with confounding
- [Section 6.2: Binary Treatment & QTE](vignettes/Section6_2.Rmd) — Quantile treatment effects
- [Section 6.3: Multivariate X](vignettes/Section6_3.Rmd) — Multiple endogenous variables
- [Section 6.4: Instrument Strength](vignettes/Section6_4.Rmd) — Weak vs strong instruments

### Real-Data Applications (Paper Section 7)

- [Section 7.1: Colonial Origins](vignettes/Section7_1.Rmd) — Acemoglu et al. institutional quality and development
- [Section 7.2: Single-Cell Biology](vignettes/Section7_2.Rmd) — Gene expression generalizability

## References

- Holovchak, A., Saengkyongam, S., Meinshausen, N., & Shen, X. (2025). Distributional Instrumental Variable Method. arXiv:2502.07641.
- Shen, X. & Meinshausen, N. (2024). Engression: Extrapolation through the Lens of Distributional Regression. JMLR.
