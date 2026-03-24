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

### Simulation Studies (Paper Sections 3 & 5)

- [Section 3.3: Softplus Example](vignettes/Section3_3.Rmd) — Motivating example with distributional overlap and density comparisons
- [Section 5.1: Sinusoidal DGP](vignettes/Section5_1.Rmd) — Nonlinear post-additive noise outcome model
- [Section 5.2: Binary Treatment & QTE](vignettes/Section5_2.Rmd) — Quantile treatment effects with logistic DGP
- [Section 5.3: Multivariate X](vignettes/Section5_3.Rmd) — Multiple endogenous variables with partial interventional mean
- [Section 5.4: Instrument Strength](vignettes/Section5_4.Rmd) — DIV robustness to weak instruments (alpha=0 vs alpha=2)

### Real-Data Applications (Paper Section 6)

- [Section 6.1: Colonial Origins](vignettes/Section6_1.Rmd) — Acemoglu et al. (2001), DIV vs 2SLS vs OLS
- [Section 6.2: Single-Cell Biology](vignettes/Section6_2.Rmd) — Sachs et al. (2005) protein signaling generalizability

## References

- Holovchak, A., Saengkyongam, S., Meinshausen, N., & Shen, X. (2025). Distributional Instrumental Variable Method. arXiv:2502.07641.
- Shen, X. & Meinshausen, N. (2024). Engression: Extrapolation through the Lens of Distributional Regression. JMLR.
