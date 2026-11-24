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

**Prepared, not yet executed on a fresh GitHub clone.** The previous 7/7 clean-clone success applies to archived **statistical CSV reprocessing**, not this frozen simulator rerun. Update this statement after a successful user-provided console log.
