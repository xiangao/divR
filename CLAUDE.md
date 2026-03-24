# CLAUDE.md

## Project Overview

divR implements Distributional Instrumental Variable (DIV) regression in R, based on Holovchak, Saengkyongam, Meinshausen & Shen (2025, arXiv:2502.07641). Uses energy score-based generative modelling to estimate the full interventional distribution P(Y|do(X)) in the presence of unmeasured confounding.

Based on the `DistributionIV` CRAN package by the same authors (`~/projects/claude/frengression/DistributionIV/`), with bug fixes, additional vignettes, and a test suite.

## Build & Install

```bash
cd ~/projects/software
R CMD build divR --no-build-vignettes
R CMD INSTALL divR_0.1.0.tar.gz
```

## Testing

```bash
cd ~/projects/software/divR
Rscript -e 'testthat::test_dir("tests/testthat")'
```

33 tests covering: output structure, predict dimensions (mean/sample/quantile), print method, input validation, energy loss, check_input.

## Architecture

Two coupled generative networks sharing a hidden confounder noise dimension:
- **gen_g**: X = g(Z, eps_x, eps_h) — treatment given instruments
- **gen_f**: Y = f(X, eps_y, eps_h) — outcome given treatment

Noise order in training and prediction must match: `[input, eps_specific, eps_h, (W)]`.

### Key files
- `R/divR.R` — Main function with input validation and standardization
- `R/divRfit.R` — Internal fitting (torch training loop, network construction)
- `R/predict.divR.R` — S3 predict method (mean, sample, quantile with trim/drop)
- `R/print.divR.R` — S3 print method
- `R/nnmodel.R`, `R/energyloss.R` — Shared utilities from DistributionIV

## Vignettes

7 vignettes reproducing the paper: Sections 3.3, 5.1–5.4 (simulations), 6.1–6.2 (real data).

Render: `Rscript -e "rmarkdown::render('vignettes/Section5_1.Rmd')"`

Use `cache: false` for all torch-dependent chunks.

## Dependencies

- `checkmate` (Imports) — input validation
- `torch` (Suggests) — neural network backend; requires `torch::install_torch()` for libtorch
