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

## Frozen simulator verification — 4/4 scenarios passed

A separate **four-scenario, single-replication-per-scenario** simulator comparison is now prepared at `scripts/VERIFY_FROZEN_SIMULATOR.R`. It re-generates four runs using the original frozen R functions, configuration and prespecified seeds, then compares 28 method-level rows and 56 subgroup rows with archived benchmark values.

```sh
Rscript --vanilla scripts/VERIFY_FROZEN_SIMULATOR.R
```

**Status: author-executed fresh-clone run PASSED on Windows (24 November 2026).** Replication 1 was regenerated for each of four scenarios using seed 30261124, and all five checks passed with exit code 0. The largest numerical difference was 4.618528e-14. The test verifies four regenerated runs, **not all 800**. See [the audit record](audits/2026-11-24_fresh_clone_simulator_verification.md) and [instructions](documentation/HOW_TO_VERIFY_SIMULATOR.md).

## Full 800-run simulator verification — PASSED (author-run)

Following the successful four-scenario check, the author completed a **resumable full 800-run audit**. It uses the original frozen functions, checks the same method-level and regime-level values for every scenario/replication, and records a durable pass/fail result after each run.

```sh
Rscript --vanilla scripts/VERIFY_ALL_800.R --batch=20
Rscript --vanilla scripts/VERIFY_ALL_800.R --status
```

The script supports resumable batches and `--all`. **On 24 November 2026, the author's fresh-clone Windows rerun completed: 800/800 simulations passed, 0 unsuccessful attempts, 0 outstanding, and exit status 0.** See [the full 800-run audit](audits/2026-11-24_full_800_complete.md) and [reproduction instructions](documentation/HOW_TO_VERIFY_ALL_800.md). This verifies regenerated summary outputs numerically; it does not reconstruct the historical checkpoint RDS files.

## Preserved full-audit evidence — 800/800 verified records

The author has supplied the complete, original Windows audit artifacts. They are archived in [`audits/full_800_evidence/`](audits/full_800_evidence/) and independently checked at the CSV record level:

- [800 replication results](audits/full_800_evidence/replication_checks.csv): 800 distinct scenario–replication keys; all passed; no missing/duplicate records, failures, or unverified seeds
- [13-file input MD5 manifest](audits/full_800_evidence/input_md5.csv): locked input hashes recorded by the local run
- [R session environment](audits/full_800_evidence/session_info.txt): R 4.5.2, Windows 11, data.table 1.18.6.1

Across 800 records, maximum method error was **5.684342e-14** and maximum regime error **6.661338e-16**, both below `1e-10`. See the [detailed evidence review](audits/2026-11-24_full_800_detailed_evidence_review.md). These are author-run results (not third-party CI), and checkpoint RDS contents are not included.

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

On the author's original workstation, the 800 archived checkpoint MD5 checks passed, statistical tables reproduced in a clean R session (maximum difference around 5.33e-14), and one frozen replication from each of the four scenarios was re-executed successfully in separate R processes. These historical checks preceded the subsequently completed author-executed fresh-clone reproduction of all 800 scenario–replication runs.

**The repository supports author-tested standalone numerical regeneration of the full 800-run synthetic benchmark on Windows.** The frozen configuration, scenarios, seeds, archived benchmark metrics, subgroup results, and statistical reference summaries are present. The author successfully ran `scripts/VERIFY_ALL_800.R` from a fresh GitHub checkout (800/800 passed). The 800 original checkpoint RDS files are not included; binary checkpoint equality, automated cross-platform validation and third-party independent replication have not been established. Some original functions reference run-specific configuration constants. The plotting script is bound to the original workstation path, although its benchmark CSV inputs are now uploaded. The frozen simulator audit and statistical reprocessing entry points have been tested by the author from a fresh checkout; unrelated historical scripts and figure generation may still require original workstation-specific dependencies.

## Source provenance

The files in `src/` were replaced with the **original frozen `.R` files uploaded by the author**. Their original workstation MD5 hashes matched the supplied source-integrity and source-lock manifests before uploading. Text line endings were normalized during upload, so original byte hashes are not GitHub byte hashes. A fresh-clone author-run audit has now successfully regenerated all 800 scenario–replication runs and matched archived summaries within the prespecified tolerance.

## Independent external replication — invitation open

The complete 800-run numerical audit was **executed by the author**, not an outside researcher. A full third-party replication package is available:

- [External replication protocol](documentation/INDEPENDENT_EXTERNAL_REPLICATION_PROTOCOL.md)
- [Independent reviewer report template](documentation/EXTERNAL_REPLICATION_REPORT_TEMPLATE.md)
- [Objective pass/fail checklist](documentation/EXTERNAL_REPLICATION_CHECKLIST.csv)
- [Reserved external evidence directory](audits/external_replication/README.md)

**External replication status: not yet completed or certified.** A prospective reviewer must independently clone a fixed Git commit, execute the seven statistical checks and all 800 frozen simulations, provide their own audit files, and explicitly approve the final report. The existing 800/800 author-run verification must not be misrepresented as third-party confirmation.

## Funding and competing interests

The author reports **no funding** and **no competing interests**.

## Licensing

**MIT License.** Copyright (c) 2026 Peter Sarpong. See [LICENSE](LICENSE). The license permits use, modification, redistribution and commercial use subject to preserving its copyright and permission notice; no warranty is supplied. Third-party materials, if any, retain their own rights.

## Published GitHub release and Zenodo archive

**Published GitHub Release: [`v4.1.5`](https://github.com/petersarpong1157-cmyk/raac-delayed-feedback-calibration/releases/tag/v4.1.5), archived on Zenodo with DOI [`10.5281/zenodo.24514208`](https://doi.org/10.5281/zenodo.24514208).** The repository includes [Zenodo metadata](.zenodo.json), [GitHub citation metadata](CITATION.cff), and [historical v4.1.4 draft release notes](documentation/RELEASE_NOTES_v4.1.4.md). The MIT license is included at [LICENSE](LICENSE).

Zenodo displays this GitHub snapshot as **v4.1.5**. **Citation warning:** the files *inside the tagged snapshot* still specify version **4.1.4** in `.zenodo.json` and `CITATION.cff` (the tag was created before the release-version metadata was adjusted). These metadata files have been corrected on `main` for future use, but the archived tag remains unchanged. Check the Zenodo record's displayed version and correct it using Zenodo metadata editing if needed. The MIT `LICENSE` is included in the released tag; verify the Zenodo record's displayed license. The manuscript and rendered figures remain excluded.

## Publication

The software and reproducibility archive has a Zenodo DOI (`10.5281/zenodo.24514208`). This does **not** constitute journal acceptance or publication of the associated research manuscript, which remains excluded intentionally.
