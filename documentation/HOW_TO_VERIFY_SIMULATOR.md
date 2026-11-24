# Clean-clone Frozen Simulator Check

**Scope:** regenerate one selected replication from each of the four scenarios using the exact stored seed plan, original frozen functions, and frozen RDS configuration, then compare 28 method summaries and 56 subgroup rows against the archived 800-run benchmark.

## Run

From Windows RStudio, with `data.table` installed and a fresh checkout at `C:/your/path/raac-delayed-feedback-calibration`:

```r
repo <- "C:/your/path/raac-delayed-feedback-calibration"
script <- file.path(repo, "scripts", "VERIFY_FROZEN_SIMULATOR.R")
stopifnot(file.exists(script))
status <- system2(
  file.path(R.home("bin"), "Rscript.exe"),
  args = c("--vanilla", shQuote(script))
)
print(status)
```

**Do not run the R script via `source()`.** It determines paths from `Rscript --file`.

Alternatively, in a terminal at repository root:

```sh
Rscript --vanilla scripts/VERIFY_FROZEN_SIMULATOR.R
```

A passing run reports five `TRUE` rows, numerical differences below `1e-10` and process status `0`. Upload the console output and `reproduction_outputs/frozen_simulator_audit.csv` after execution to archive this evidence in GitHub.

## What this test actually does

- Four scenarios, all at replication 1, using the frozen final seed schedule.
- Regenerates the synthetic data and re-estimates the frozen point forecaster for those four runs.
- Reissues the four expert intervals, RAAC, Equal Weight, and the ACI comparator, then scores them.
- Compares regenerated method-level and regime-level numerical outputs against the originally archived tables.
- Outputs test audit, errors, reconstructed summaries and R session details to `reproduction_outputs/`.

## What it does not do

- Regenerate all 800 simulations
- Verify every historical binary checkpoint
- Establish real-world predictive validity or any formal conditional coverage guarantee
- Replace the original source and checksums with new versions

## Status as of 24 November 2026

**Author-run verification passed on 24 November 2026.** A fresh GitHub clone on Windows regenerated one final-seed replication in each of four scenarios. All five checks passed, maximum absolute difference 4.618528e-14, and Rscript exited with status 0. See `audits/2026-11-24_fresh_clone_simulator_verification.md`. This is distinct from the earlier successful 7/7 CSV-level statistics test and is not an 800-run simulation rerun.
