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

## Latest additions: archived reproduction audit

- `scripts/REPRODUCE_ANALYSIS.R`: canonical, successfully tested Step 67 statistical reprocessing script. **Not currently runnable from this GitHub checkout**: requires the remaining original 30-file release tree and historical manifest checksums. Do not remove or bypass those checks simply to make it run.
- `audits/`: Step 67 audit and clean-session logs. These document a run performed on the author's Windows workstation, **not a rerun from GitHub**.
- `environment/`: R version and package versions recorded for the original workstation.
- `documentation/HISTORICAL_30_FILE_MANIFEST.csv`: checksum manifest of the original 30-file release, **not** an inventory or checksum manifest of this GitHub repository.
- `documentation/HOW_TO_REPRODUCE_ORIGINAL.md`: instructions that apply to the **complete original release**, once reconstructed.

## Repository structure

- `src/`: the eight original R source files supplied by the author (line endings normalized during GitHub upload), replacing earlier recovered function extracts.
- `scripts/`: the historical Step 67 statistical reproduction script and the research visualization script. The latter retains a workstation-specific path, and no figures are included.
- `documentation/`: technical methods, protocol amendment, original-release instructions, historical checksum records, and provenance notes.
- `audits/`: original workstation reproduction logs and a Step 67 audit.
- `environment/`: original R session and package versions.
- `results/`: the frozen binary configuration, scenario definitions, 800-seed schedule, both complete 800-run benchmark CSVs, and the original checkpoint checksum manifest.
- `.gitignore`: excludes temporary R files, rendered figures, manuscript materials, and large checkpoint artifacts.

## Reproducibility: clearly separated claims

On the author's original workstation, the 800 archived checkpoint MD5 checks passed, statistical tables reproduced in a clean R session (maximum difference around 5.33e-14), and one frozen replication from each of the four scenarios was re-executed successfully in separate R processes. Those results were verified against the archived benchmark and do **not** mean the complete 800-run benchmark has been regenerated in a fresh clone.

**This repository is not yet a validated standalone full-reproduction package.** The frozen configuration RDS, scenario CSV, seed schedule, archived metrics and subgroups are now present. However, the reference summary tables required by the Step 67 statistical audit, the original 800 checkpoint RDS files, and a tested clean-clone simulator reproduction entry point are still missing. Some original functions reference run-specific configuration constants. The plotting script is bound to the original workstation path, although its benchmark CSV inputs are now uploaded. Do not advertise the repository as fully executable or complete until those dependencies are added and tested.

## Source provenance

The files in `src/` were replaced with the **original frozen `.R` files uploaded by the author**. Their original workstation MD5 hashes matched the supplied source-integrity and source-lock manifests before uploading. Text line endings were normalized during upload, so original byte hashes are not GitHub byte hashes. Reproduction from a fresh clone still needs verification.

## Funding and competing interests

The author reports **no funding** and **no competing interests**.

## Licensing

No reuse license has yet been granted. Open repository visibility does not itself grant an open-source license.

## Publication

No journal acceptance, publication, or DOI is claimed. Publication materials are excluded intentionally.
