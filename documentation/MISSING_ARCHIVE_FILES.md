# Remaining Computational Archive Files

**Updated 24 November 2026.** This inventory identifies files needed beyond what is currently hosted in GitHub. Manuscript and figures remain intentionally excluded.

## Now available in GitHub

- Eight original uploaded R source files under `src/`, replacing reconstructed extracts (text normalized to LF during upload)
- Frozen configuration RDS and prespecified scenario CSV
- Independent 800-row seed schedule and protocol amendment
- 5,600-row method-level metrics and 11,200-row subgroup metrics
- 800-row checkpoint MD5 manifest (the checkpoint RDS files themselves are not included)
- Original source integrity/lock and Step 52 audit records
- Verified historical `scripts/REPRODUCE_ANALYSIS.R` and audit logs

## Still required for the clean-session statistical reprocessing script

- `results/step55_statistical_analysis/seven_method_summary.csv`
- `results/step55_statistical_analysis/primary_raac_vs_fixed_global.csv`
- `results/step55_statistical_analysis/secondary_raac_comparisons.csv`
- `results/step56_regime_reliability/regime_method_summary.csv`
- Full `RELEASE_FILE_MANIFEST.csv` reconstruction for the current GitHub layout. The existing historical 30-file manifest refers to the workstation release and original Windows line endings and must **not** be used as a verified GitHub checksum manifest.

The original script currently expects to be run from the root of the **full original release**, where its manifest and dependencies exist. A fresh GitHub clone is not yet a validated standalone reproduction.

## Still required for full simulator replication

- A tested clean-session simulator entry point and verified runtime constants.
- Direct reproduction of the published four-scenario verification workflow from a clean clone.
- Software environment checks on a fresh machine.
- Optional external archive containing all 800 original checkpoint RDS files. Their historical MD5 manifest is now on GitHub, but the archive is not.

## Audit cautions

- Uploaded plain-text files are normalized from the original Windows CRLF line endings to LF; their historical MD5 hashes therefore differ even when their content is equivalent.
- The frozen binary configuration RDS was uploaded byte-for-byte.
- A manifest records the original checkpoint filenames and hashes but does not prove the checkpoint files are downloadable.
- The supplied `step52_manifest.csv` mentions a `benchmark_readiness.csv` that has **not** been supplied in this turn.
- No manuscript or figure data is published in this GitHub repository.
