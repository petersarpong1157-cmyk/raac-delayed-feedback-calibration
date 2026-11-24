# Full 800-Run Frozen Simulator Reproduction — COMPLETE (Author-Run)

**Date:** 24 November 2026  
**Status:** **800/800 passed; 0 unsuccessful attempts; 0 pending**  
**Source:** Author-provided Windows RStudio console records, including `Pasted text(20261124-200835).txt` for the final batch. This is a record of an author-executed run, not third-party independent verification or automated continuous integration.

## Design and audited scope

- Four prespecified volatility scenarios, with 200 replications per scenario.
- Re-executed the original frozen R simulator and scoring implementation from the GitHub checkout, with frozen configuration and precommitted scenario/replication seeds.
- At each replication, checked the seven method-level summaries and 14 scenario/replication/method/regime subgroup rows against the archived benchmark within the script's `1e-10` absolute tolerance.
- Each replication's pass/fail result was persisted locally in `reproduction_outputs/full_800_audit/replication_checks.csv`; the script locked MD5s of inputs across batch invocations.

## Execution history

| Stage | Incremental passing runs | Cumulative passes | Unsuccessful attempts |
|---|---:|---:|---:|
| Initial batch | 20 | 20 | 0 |
| Second batch | 20 | 40 | 0 |
| Third batch | 20 | 60 | 0 |
| Large batch | 500 | 560 | 0 |
| Final batch | 240 | **800** | **0** |

The final command supplied by the author was:

```r
status <- system2(
  file.path(R.home("bin"), "Rscript.exe"),
  c("--vanilla", shQuote(script), "--batch=500")
)
print(status)
```

Although `--batch=500` was passed, the script automatically selected the **240 unverified** replications, which all passed. The final batch covered `Sudden_Volatility_Increase` replications 161–200 (40 runs) and `Volatility_Reversal` replications 1–200 (200 runs). Its final line was `[240/240] Volatility_Reversal replication 200 seed 30261323 ... PASS`.

## Scenario-level outcomes

| Scenario | Verified replications |
|---|---:|
| Gradual_Volatility_Increase | 200/200 |
| Stable | 200/200 |
| Sudden_Volatility_Increase | 200/200 |
| Volatility_Reversal | 200/200 |
| **TOTAL** | **800/800** |

## Final console evidence

```text
Progress: 800 / 800 passed; 0 unsuccessful attempts; 0 not passed
PASS: All 800 frozen simulator runs matched the archived tables.
> print(status)
[1] 0
```

A nonfatal `data.table` R-build-version warning appeared. The Rscript process exited successfully (`0`).

## Reproducibility claim and remaining limitations

**Supported claim:** The author successfully regenerated all 800 prespecified scenario–replication simulations using the frozen code and seeds from a fresh GitHub checkout and matched the archived method and regime summary outputs within `1e-10`. Separately, the author passed all seven clean-clone archived statistical reprocessing tests.

**Do not overstate:** This evidence is author-run and drawn from user-supplied console logs. The original 800 binary checkpoint RDS files are not reconstructed or independently audited from GitHub; raw generated per-origin predictions are not byte-comparison-verified. No third-party independent rerun, multi-platform CI, real-world evaluation, or distribution-free conditional coverage guarantee is claimed.

**Preserve author evidence:** Before preparing a versioned public archive release, obtain the local `replication_checks.csv`, `input_md5.csv`, and `session_info.txt` from `reproduction_outputs/full_800_audit/` for archiving. No manuscript or rendered figures are included.
