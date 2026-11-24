# Remaining Computational Reproduction Work

**Updated 24 November 2026.** The complete four-scenario benchmark CSVs and four original statistical reference tables are now published in this repository. Manuscript and figures remain intentionally excluded.

## Present and published

- Eight original frozen R source files under `src/`
- Original configuration RDS, scenario definitions and 800-row seed schedule
- 5,600 archived method-level observations and 11,200 subgroup records
- Four reference statistical tables: `seven_method_summary.csv`, `primary_raac_vs_fixed_global.csv`, `secondary_raac_comparisons.csv` and `regime_method_summary.csv`
- Paired replication differences, scenario method rankings, RAAC regime coverage and supporting summary tables
- Source-lock records, original checkpoint manifest and protocol amendment
- Historical Step 67 verified script and original workstation audit logs
- New `scripts/REPRODUCE_GITHUB_ANALYSIS.R` entry point adapted to the repository layout

## Run statistical reprocessing

From the GitHub repository root, with R and `data.table` installed:

```sh
Rscript --vanilla scripts/REPRODUCE_GITHUB_ANALYSIS.R
```

This regenerates and compares method, paired contrast and subgroup summaries against the uploaded references, with a numerical tolerance of `1e-10`. It writes evidence to `reproduction_outputs/` (ignored by Git).

**The new GitHub-layout script has not been run here.** The historical Step 67 log verifies a successful workstation run using the original 30-file distribution, not a tested fresh GitHub clone. Run the command in a fresh clone and retain the output log before claiming the GitHub layout passes.

## Remains to be done

1. Execute the GitHub-layout script from an actual fresh checkout, confirm all checks pass and archive a new clean-session audit log.
2. Provide a clean-clone simulator driver with source dependencies and verified ACI bounds, and independently rerun the four-scenario single-replication benchmark.
3. Create a checksum manifest for the current public GitHub release (the historical 30-file manifest does **not** describe GitHub bytes).
4. Optionally archive the 800 original checkpoint RDS files separately; only their MD5 manifest is on GitHub.
5. Do not publish manuscript or figure artifacts here unless the author changes that instruction.

The observed results are synthetic and make no external real-world or distribution-free conditional coverage claims.
