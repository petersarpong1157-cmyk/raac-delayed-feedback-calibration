# Release-Aware Adaptive Calibration Under Delayed Feedback

**Author:** Peter Sarpong · **Affiliation:** Independent Researcher

This repository collects research **code and reproducibility documentation** for a synthetic benchmark of Release-Aware Adaptive Calibration (RAAC), a delayed-feedback aggregation of four prediction-interval calibration experts. The manuscript and figures are intentionally **not included** in this repository, at the author's request.

## Study design

- Four volatility scenarios: Stable, Gradual Volatility Increase, Sudden Volatility Increase, and Volatility Reversal.
- 200 independent replication seeds per scenario (800 scenario–replication runs), with seven interval methods.
- Nominal coverage target of 90%. Cohorts affect adaptive updates only after every observation in the cohort has been released strictly before the new forecast origin.
- The final seed schedule followed a documented protocol amendment.

## Findings

RAAC improved mean interval score relative to Fixed Global by 2.26%–7.49%, but improved on Equal Weight by less than 0.07%. Fixed Conditional achieved lower mean score than RAAC in all four scenarios; Rolling Conditional led in the sudden-shift case. RAAC's Regime 1 coverage ranged from 72.02% to 84.44%, despite overall coverage of approximately 89.55%–90.50%. These are **simulation findings** without a distribution-free conditional-coverage guarantee or independent real-world validation.

## Statistical reprocessing from a GitHub checkout

The archived benchmark data and all four statistical reference tables are now in the repository. With R and `data.table` installed, run:

```sh
Rscript --vanilla scripts/REPRODUCE_GITHUB_ANALYSIS.R
```

This new script compares the archived 800-run method-level, paired and regime statistical summaries with their independently recomputed values; it does **not** regenerate simulations. On 24 November 2026, the author executed it after a fresh GitHub clone on Windows: all seven reported checks passed, the largest numerical discrepancy was 5.329071e-14, and Rscript exited with status 0. See `audits/2026-11-24_fresh_clone_statistical_reproduction.md`. This was author-executed, not automated or cross-platform verification. The historical `scripts/REPRODUCE_ANALYSIS.R` performs extra original-distribution checksum checks and is maintained as archival evidence.

## Frozen simulator verification (next test)

A separate **four-scenario, single-replication-per-scenario** simulator comparison is now prepared at `scripts/VERIFY_FROZEN_SIMULATOR.R`. It re-generates four runs using the original frozen R functions, configuration and prespecified seeds, then compares 28 method-level rows and 56 subgroup rows with archived benchmark values.

```sh
Rscript --vanilla scripts/VERIFY_FROZEN_SIMULATOR.R
```

**Status: awaiting fresh-clone execution.** The author's prior passing 7/7 fresh-clone run verified CSV-level statistical reprocessing only. This new script has not yet been independently executed or certified. See [documentation/HOW_TO_VERIFY_SIMULATOR.md](documentation/HOW_TO_VERIFY_SIMULATOR.md).

## Latest additions: archived reproduction audit

- `scripts/REPRODUCE_ANALYSIS.R`: canonical, successfully tested Step 67 statistical reprocessing script. **Not currently runnable from this GitHub checkout**: requires the remaining original 30-file release tree and historical manifest checksums. Do not remove or bypass those checks simply to make it run.
- `audits/`: Step 67 audit and clean-session logs. These document a run performed on the author's Windows workstation, **not a rerun from GitHub**.
- `environment/`: R version and package versions recorded for the original workstation.
- `documentation/HISTORICAL_30_FILE_MANIFEST.csv`: checksum manifest of the original 30-file release, **not** an inventory or checksum manifest of this GitHub repository.
- `documentation/HOW_TO_REPRODUCE_ORIGINAL.md`: instructions that apply to the **complete original release**, once reconstructed.

## Repository structure

- `src/`: the eight original R source files supplied by the author (line endings normalized during GitHub upload), replacing earlier recovered function extracts.
- `scripts/`: original Step 67 historical reproduction script, a new GitHub-layout statistical reprocessing entry point, and the research visualization script (the latter retains a workstation-specific path; no figures are included).
- `documentation/`: technical methods, protocol amendment, original-release instructions, historical checksum records, and provenance notes.
- `audits/`: original workstation reproduction logs and a Step 67 audit.
- `environment/`: original R session and package versions.
- `results/`: frozen binary configuration, scenarios, 800-seed schedule, both complete benchmark CSVs, the reference summary tables, paired replication records and checkpoint checksum manifest.
- `.gitignore`: excludes temporary R files, rendered figures, manuscript materials, and large checkpoint artifacts.

## Reproducibility: clearly separated claims

On the author's original workstation, the 800 archived checkpoint MD5 checks passed, statistical tables reproduced in a clean R session (maximum difference around 5.33e-14), and one frozen replication from each of the four scenarios was re-executed successfully in separate R processes. Those results were verified against the archived benchmark and do **not** mean the complete 800-run benchmark has been regenerated in a fresh clone.

**This repository is not yet a validated standalone full-simulation reproduction package.** Frozen configuration, scenarios, seeds, archived benchmark metrics, subgroup results, and all four statistical reference summaries are present. The 800 original checkpoint RDS files and a verified clean-clone full-simulator driver are not included. The GitHub-layout statistical reproduction script passed an author-executed clean-clone test on Windows; an automated cross-platform validation and full simulation rerun are still outstanding. Some original functions reference run-specific configuration constants. The plotting script is bound to the original workstation path, although its benchmark CSV inputs are now uploaded. Do not advertise the repository as fully executable or complete until those dependencies are added and tested.

## Source provenance

The files in `src/` were replaced with the **original frozen `.R` files uploaded by the author**. Their original workstation MD5 hashes matched the supplied source-integrity and source-lock manifests before uploading. Text line endings were normalized during upload, so original byte hashes are not GitHub byte hashes. Reproduction from a fresh clone still needs verification.

## Funding and competing interests

The author reports **no funding** and **no competing interests**.

## Licensing

No reuse license has yet been granted. Open repository visibility does not itself grant an open-source license.

## Publication

No journal acceptance, publication, or DOI is claimed. Publication materials are excluded intentionally.
