# Full 800-Run RAAC Simulator Audit

**Current state:** Prepared but **not yet executed**. Do not claim that all 800 runs reproduced until the saved audit shows all 800 `passed == TRUE`.

## Purpose

The verified research benchmark contains **four volatility scenarios × 200 replications = 800 independent scenario–replication runs**, with seven methods and two regime summaries per method. This script reruns the **original frozen** source methods with their locked configuration and seeds, computes fresh evaluation summaries, and compares them with the archived method-level and subgroup-level results. It does not alter those sources or the archive.

The earlier fresh-clone tests separately passed:
- Archived statistical CSV reprocessing: 7/7 checks
- Frozen simulator regeneration: replication 1 in each scenario (4/800): 5/5 checks

The full 800-run verification is separate from those audits.

## Run on Windows (RStudio)

First clone the **latest** GitHub repository into a permanent folder outside `tempdir()`:

```r
repo <- "C:/Users/peter/Downloads/raac-800-verification"

if (dir.exists(repo)) stop("Folder already exists. Choose a new directory.")
clone <- system2("git", c(
  "clone",
  shQuote("https://github.com/petersarpong1157-cmyk/raac-delayed-feedback-calibration.git"),
  shQuote(repo)
))
stopifnot(clone == 0)

script <- file.path(repo, "scripts", "VERIFY_ALL_800.R")
stopifnot(file.exists(script))

# Run the first 20 replications; results persist after each run.
status <- system2(file.path(R.home("bin"), "Rscript.exe"),
  c("--vanilla", shQuote(script), "--batch=20"))
print(status)
```

Repeat this command with the **same repo folder**, without cloning or modifying source files:

```r
status <- system2(file.path(R.home("bin"), "Rscript.exe"),
  c("--vanilla", shQuote(script), "--batch=20"))
print(status)
```

You may use `--batch=50` instead, or `--all` to continue every remaining replication in one uninterrupted invocation. On a busy machine, prefer smaller batches so the audit can be resumed easily.

To check progress without rerunning anything:

```r
system2(file.path(R.home("bin"), "Rscript.exe"),
  c("--vanilla", shQuote(script), "--status"))
```

## Expected output

Progress is written to:

`reproduction_outputs/full_800_audit/replication_checks.csv`

The script also writes:

- `input_md5.csv`: hashes of the data, frozen source, and seed inputs used for the audit
- `session_info.txt`: tested R environment

For **each** run, the audit checks:

- exactly seven matching method rows with the same `scenario`, `replication`, and `method` keys;
- exactly 14 matching regime rows with the same regime identifiers;
- method sample size, mean score, coverage, mean width, minimum regime coverage and worst-regime shortfall;
- regime sample sizes and coverage values;
- all numerical differences below `1e-10`.

Successful completion is announced only after **800/800** have passed. A failed attempt remains in the CSV and is eligible for retry. Check the `error_message` column before investigating failures. An unfinished batch may still exit with status 0 when all *attempted* runs passed; always check `--status` for the full 800 count.

## Integrity precautions

- Do not change the frozen algorithms, configuration, scenario table, seed schedule or archived metrics while a run is in progress.
- The script checks MD5 of its input files at each invocation and refuses to append runs if these change.
- Do not publish generated outputs as established results until they have been reviewed.
- This does not regenerate or verify the **800 historical checkpoint RDS files** themselves.
- This is an author-run computational reproduction, not third-party independent replication, cross-platform validation or proof of real-world generalization.
- **No manuscript or figures are included in this repository.**

## Next action after 800/800 pass

Provide `replication_checks.csv`, `input_md5.csv`, `session_info.txt`, and the console summary. These can then be audited, committed under `audits/`, and referenced in a versioned release, without including manuscript or figure files.
