# RAAC v1.0.0 — Initial Public Reproducible Software Release

**Release tag to create:** `v1.0.0`  
**Release title:** `RAAC Frozen Benchmark v1.0.0 — Code, Data & Reproduction Evidence`  
**Licensing:** MIT License (Copyright © 2026 Peter Sarpong)  
**Status:** Prepared release notes; not yet a published GitHub Release or minted Zenodo DOI.

## Archive scope

This release packages the computational materials for *Release-Aware Adaptive Calibration Under Delayed Feedback: Prediction-Interval Efficiency and Conditional Coverage Across Volatility Regimes*.

Included:
- Original frozen R source code implementing synthetic data generation, point forecasting, calibration experts, RAAC, the ACI comparator, simulation and scoring
- Prespecified four volatility scenarios, frozen configuration and final 800-row seed schedule
- 5,600 method-level and 11,200 regime-level benchmark rows
- Archived statistical comparison and conditional-regime reliability outputs
- Statistical reprocessing (`scripts/REPRODUCE_GITHUB_ANALYSIS.R`) and resumable full frozen simulator rerun (`scripts/VERIFY_ALL_800.R`)
- Author-executed detailed numerical reproduction evidence for **800/800 passing scenario–replication runs**, plus input integrity and R environment records
- Documentation, protocol notes, objective verification protocol, citation metadata and MIT license

Excluded by author request:
- Research manuscript and associated editorial files
- Rendered publication figures, plots and PDF visualizations
- 800 original RDS checkpoint binaries (historical audit covers them separately; GitHub benchmark regeneration checks numerical output summaries, not checkpoint byte equality)

## Research findings (simulation only)

The RAAC method improved mean interval score compared with the Fixed Global calibration benchmark by approximately 2.26%–7.49% across the four scenarios. Improvements over Equal Weight were less than 0.07%; Fixed Conditional outperformed RAAC in all four scenarios. High-volatility sparse-regime coverage was materially below the nominal 90% target despite near-nominal aggregate coverage.

These findings are limited to the frozen synthetic benchmarking setup; the repository does not claim a universal conditional coverage guarantee or empirical validation.

## Reproduction commands

Run with R and `data.table` installed:

```sh
Rscript --vanilla scripts/REPRODUCE_GITHUB_ANALYSIS.R
Rscript --vanilla scripts/VERIFY_ALL_800.R --all
Rscript --vanilla scripts/VERIFY_ALL_800.R --status
```

The 800-run script saves progress under `reproduction_outputs/full_800_audit/` and may be resumed with `--batch=N`.

## Numerical reproduction and limits

On 24 November 2026, the author ran the frozen 800-replication simulator from a fresh Windows GitHub checkout; all 800 checks passed with no unsuccessful attempts. The archived test records report maximum method error `5.684342e-14` and maximum regime error `6.661338e-16`, both below the prespecified `1e-10` threshold. Independent third-party replication, cross-platform CI and real-world application validation have **not** been completed.

## Referencing and citation

The release includes a `CITATION.cff` for GitHub citation suggestions and `.zenodo.json` for Zenodo metadata, with `license: mit`. The Zenodo DOI should be added to the README after Zenodo successfully archives the actual GitHub v1.0.0 release; do not fabricate one.

**No manuscript publication or journal acceptance is implied by this software release.**
