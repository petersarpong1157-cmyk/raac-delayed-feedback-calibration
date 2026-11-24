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

**The author successfully ran the GitHub-layout script from a fresh clone on Windows on 24 November 2026**, passing 7/7 checks. That evidence is documented in `audits/2026-11-24_fresh_clone_statistical_reproduction.md`. This does not regenerate the underlying 800 simulations.

## Remains to be done

1. Completed 24 November 2026: the author ran the GitHub-layout statistical script from a fresh clone (7/7 checks passed). See `audits/2026-11-24_fresh_clone_statistical_reproduction.md`.
2. Completed 24 November 2026: a four-scenario, single-replication-per-scenario frozen simulator clean-clone test passed (5/5 checks). See `audits/2026-11-24_fresh_clone_simulator_verification.md`. A full 800-run rerun remains outstanding.
3. Create a checksum manifest for the current public GitHub release (the historical 30-file manifest does **not** describe GitHub bytes).
4. Optionally archive the 800 original checkpoint RDS files separately; only their MD5 manifest is on GitHub.
5. Do not publish manuscript or figure artifacts here unless the author changes that instruction.

The observed results are synthetic and make no external real-world or distribution-free conditional coverage claims.
