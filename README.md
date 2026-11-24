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

## Repository structure

- `src/`: function definitions **extracted from the frozen source-function documentation**. They are organized by original source filename; original frozen sources on the author's workstation remain the authority.
- `scripts/`: the archived R plotting script. It needs the archived CSV benchmark outputs and currently uses workstation-specific paths; no PDF figures are uploaded here.
- `documentation/`: technical methods and provenance notes.
- `.gitignore`: excludes temporary R files, rendered figures, manuscript materials, and large checkpoint artifacts.

## Reproducibility: clearly separated claims

On the author's original workstation, the 800 archived checkpoint MD5 checks passed, statistical tables reproduced in a clean R session (maximum difference around 5.33e-14), and one frozen replication from each of the four scenarios was re-executed successfully in separate R processes. Those results were verified against the archived benchmark and do **not** mean the complete 800-run benchmark has been regenerated in a fresh clone.

**This repository is not yet a standalone full-reproduction package.** In particular, the frozen configuration RDS, scenario CSV, seed schedule, archived metrics and subgroups, checkpoint archive, full clean-session reproduction drivers, and the audited statistical reprocessing entry point have not been uploaded. Some extracted functions reference run-specific configuration constants. The plotting script expects absent archived CSV files. Do not advertise the repository as fully executable or complete until those dependencies are added and tested.

## Source provenance

The extracted R functions in `src/` come from the available frozen-function extraction `exact_method_implementations.txt`; verify against original files on the research workstation before treating them as an authoritative distribution. Their algorithms have not been altered in this upload.

## Funding and competing interests

The author reports **no funding** and **no competing interests**.

## Licensing

No reuse license has yet been granted. Open repository visibility does not itself grant an open-source license.

## Publication

No journal acceptance, publication, or DOI is claimed. Publication materials are excluded intentionally.
