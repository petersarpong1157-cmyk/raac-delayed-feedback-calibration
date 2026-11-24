# Fresh GitHub Clone Statistical Reproduction — 24 November 2026

**Evidence:** Console output supplied by the author following a fresh `git clone` into a temporary R directory. This is an author-executed verification, not an independently witnessed run by the repository maintainer or automated continuous integration.

## Execution

- Cloned `https://github.com/petersarpong1157-cmyk/raac-delayed-feedback-calibration.git` into an R temporary directory on Windows.
- Executed `scripts/REPRODUCE_GITHUB_ANALYSIS.R` using `Rscript --vanilla`.
- Exit status: **0**.
- Reported successful completion: `PASS: GitHub archived tables statistically reproduced. No simulations regenerated.`

## Maximum numerical discrepancies

| Comparison | Maximum absolute error |
|---|---:|
| method_summary | 5.329071e-14 |
| primary_contrasts | 3.996803e-15 |
| secondary_contrasts | 4.440892e-15 |
| regime_summary | 5.551115e-16 |
| coverage_reconstruction | 1.110223e-15 |

## Checks reported as TRUE

1. Input dimensions and keys
2. Seven method summary
3. Primary paired contrasts
4. Secondary paired contrasts
5. Regime coverage table
6. Subgroup observation counts
7. Marginal/subgroup coverage reconciliation

## Software note

The console warned that `data.table` had been built under R version 4.5.3. The analysis still completed with exit status 0.

## Scope and limitations

This result validates statistical recomputation from **archived benchmark CSVs** in a fresh GitHub checkout. It does not regenerate the synthetic observations, execute the entire 800-run simulation benchmark, prove portability to operating systems other than the tested Windows system, or assess real-world generalization.

The original unmodified console output was provided in the chat and is not a signed automated CI result. No manuscript or figure artifacts are included in this repository.
