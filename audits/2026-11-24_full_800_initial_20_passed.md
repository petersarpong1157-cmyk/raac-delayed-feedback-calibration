# Full 800-Run Simulator Audit — Initial Batch (Author Console Evidence)

**Date:** 24 November 2026  
**Status:** IN PROGRESS — **20 of 800 passed**, **0 failed**, **780 remaining**.

## Provenance

This is an author-reported test performed on Windows using a fresh Git clone at `C:/Users/peter/Downloads/raac-800-verification`. The evidence is the console output supplied by the author in the conversation. This file does not claim GitHub Actions execution, independent third-party review, or completion of the 800-run audit.

## Command

```r
script <- file.path(repo, "scripts", "VERIFY_ALL_800.R")
status <- system2(
  file.path(R.home("bin"), "Rscript.exe"),
  c("--vanilla", shQuote(script), "--batch=20")
)
```

## Observed result

- Replications 1–20 of `Gradual_Volatility_Increase` all reported `PASS`.
- Seed schedule: **30261124–30261143**, consecutive.
- Console summary: `Progress: 20 / 800 passed; 0 unsuccessful attempts; 780 not passed`.
- Script message: `NOT YET VERIFIED: full 800-run simulator reproduction incomplete.`
- Rscript exit status: **0**.
- Independent `--status` invocation repeated the same summary.
- Nonfatal warning: `data.table` was built under R 4.5.3.

## Next actions

Execute additional batches from the same permanent clone, **without replacing its locked input files or deleting `reproduction_outputs/full_800_audit/`**:

```r
status <- system2(file.path(R.home("bin"), "Rscript.exe"),
  c("--vanilla", shQuote(script), "--batch=20"))
print(status)
```

The script excludes already passed scenario/replication pairs, so the next batch should begin at Gradual_Volatility_Increase replication 21. Continue until `--status` reports 800/800 passed and no unsuccessful attempts, and retain `replication_checks.csv`, `input_md5.csv` and `session_info.txt`.

**Do not claim that all 800 simulations have been reproduced until all 800 have actually passed.**
