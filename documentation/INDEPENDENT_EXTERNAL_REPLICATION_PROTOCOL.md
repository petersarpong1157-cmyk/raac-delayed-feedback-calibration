# Independent External Replication Protocol — RAAC

**Protocol version:** 1.0 · **Prepared:** 24 November 2026  
**Study:** Release-Aware Adaptive Calibration Under Delayed Feedback  
**Repository:** https://github.com/petersarpong1157-cmyk/raac-delayed-feedback-calibration  
**Lead author:** Peter Sarpong, Independent Researcher  
**Verification status:** **OPEN FOR INDEPENDENT REPLICATION — no external sign-off yet.**

## Purpose and independence standard

This protocol is for a researcher or research software specialist who was **not involved** in writing or validating the original RAAC code, choosing the frozen methods, or generating the author-reported audit. The researcher must run the tests on a computer/environment they control, maintain their own logs, and report discrepancies whether or not the tests pass.

The repository's existing author-run audit is **reference evidence**, not proof that the independent test passed. An independent run must produce new files. The outside researcher should identify themselves (or their institution) and document any prior involvement or conflicts.

## Materials already available

The repository contains:

- `src/`: original frozen R simulation and evaluation functions
- `results/step40_evaluation_design/frozen_simulation_configuration.rds` and `prespecified_scenarios.csv`
- `results/step52_final_benchmark/independent_replication_seeds.csv` (800 scenario/replication seed rows)
- `results/step54_independent_benchmark/all_replication_metrics.csv` (5,600 method rows)
- `results/step54_independent_benchmark/all_replication_subgroups.csv` (11,200 subgroup rows)
- `scripts/REPRODUCE_GITHUB_ANALYSIS.R` and `scripts/VERIFY_ALL_800.R`
- Author-run references in `audits/full_800_evidence/`

Original 800 historical checkpoint RDS files, manuscript and rendered figures are intentionally **not** part of this repository. They are **not necessary** to execute the supplied numerical verification of the frozen benchmark summaries. Do not claim these excluded items have been externally checked.

## Preparation: independent environment and immutable version

1. State your name, role, organization (if applicable), independence from the original code, operating system, R version, and `data.table` version.
2. Clone the repository into a **new, empty, permanent directory** you control. Do not use the author's local working directory or a copy of their generated audit output.
3. Record the exact Git commit SHA, date/time and whether the working tree was clean. Do **not** edit the source, configuration, seed schedule, archived results, or test scripts during the verification.
4. Install R and `data.table`. Original author environment: R 4.5.2 and `data.table` 1.18.6.1 on Windows 11. If testing another OS or version, clearly report the difference.

Example, using a terminal:

```sh
git clone https://github.com/petersarpong1157-cmyk/raac-delayed-feedback-calibration.git raac-external-test
cd raac-external-test
git rev-parse HEAD
git status --short
Rscript -e "library(data.table); print(R.version.string); packageVersion('data.table')"
```

Save the terminal output as part of your evidence.

## Test A — archived statistical analysis, 7 checks

From the root of the cloned repository:

```sh
Rscript --vanilla scripts/REPRODUCE_GITHUB_ANALYSIS.R
```

Check `reproduction_outputs/github_analysis_audit.csv` and `github_numerical_errors.csv`.

**PASS only if**:

- All seven rows in `github_analysis_audit.csv` have `passed == TRUE`.
- Input dimensions and unique keys match those specified by the script.
- Every numerical discrepancy is finite and strictly below `1e-10`.
- The process exits with status 0.

Record exact numerical discrepancies, not merely a screenshot of a success message. This stage recomputes statistical summaries from archived CSVs, **not** synthetic simulations.

## Test B — full frozen-code simulation, 800 replications

From the **same** cloned repository after Test A:

```sh
Rscript --vanilla scripts/VERIFY_ALL_800.R --all
Rscript --vanilla scripts/VERIFY_ALL_800.R --status
```

The script may also be invoked repeatedly with `--batch=100` or `--batch=500`; it saves progress after each attempt. A run must finish before a second process starts: **do not launch concurrent instances against the same output folder**. Batches with no failed attempts can exit with code 0 **even when fewer than 800 have been checked**, so verify the final CSV and `--status` output.

Review `reproduction_outputs/full_800_audit/replication_checks.csv`, `input_md5.csv`, and `session_info.txt`.

**PASS only if all of the following hold**:

- Exactly 800 rows; unique `(scenario,replication)` keys; 200 replications numbered 1–200 for each of the four scenarios.
- All 800 `passed` values are TRUE, none missing; zero failed/unfinished rows.
- Every seed matches the frozen independent seed schedule for its scenario and replication.
- Every `max_method_error` and `max_regime_error` is finite, nonnegative and strictly below `1e-10`.
- All `error_message` entries are blank.
- Exactly seven method summaries and 14 subgroup summaries were compared on every run with matching keys.
- The `--status` output says 800/800 passed; zero unsuccessful attempts; zero not passed.
- The input lock was maintained across any resumed batches; the script did not reject the manifest for changed inputs.

Record the run duration and any warnings or manual interventions. The MD5 manifest is a checksum of the local files used by the external researcher; include it so others can compare source provenance.

## Test C — independence and scientific interpretation

1. Check whether the observed result actually supports the limited claim: **numerical reproduction of archived synthetic simulation method-level and regime-level summaries**.
2. Identify any nonfrozen configuration changes, ignored errors, unusual dependencies, or undocumented manual steps.
3. Compare the externally generated tables to the archived benchmark; report failures rather than deleting or editing them.
4. Do not infer that exact summary reproduction establishes calibration under all conditional subpopulations, empirical generalizability, or validation on real data.
5. If desired, run on a different OS to strengthen portability evidence, recording platform-specific numerical differences. Cross-platform replication is helpful but not mandatory for a single independent confirmation.

## Required deliverables

Submit a report following `EXTERNAL_REPLICATION_REPORT_TEMPLATE.md`, together with:

1. `github_analysis_audit.csv` and `github_numerical_errors.csv`
2. `replication_checks.csv` (all 800 rows)
3. `input_md5.csv` and `session_info.txt`
4. Exact Git commit SHA; commands and complete process exit statuses
5. A dated statement of the reviewer's independence and a clearly signed/attributed conclusion

Do not overwrite the author's existing `audits/full_800_evidence/` files. External evidence, with reviewer consent, belongs under a reviewer-identified directory inside `audits/external_replication/`.

## Decision rules

- **PASS:** Test A and Test B meet all the numerical, cardinality and key checks; no unexplained code changes; evidence package complete.
- **PASS WITH QUALIFICATIONS:** All core checks pass but nonfatal portability/dependency issues or meaningful minor limitations should be disclosed.
- **FAIL:** At least one material numerical/key/checkpoint-scope claim fails. Do not silently exclude failed runs or move the tolerance.
- **INCOMPLETE:** Insufficient runs or missing necessary files; an exit status 0 from a partial batch is not enough.

The external researcher must select one conclusion and explain it. The project author must **not** label the work independently replicated until an independent third party has actually completed and signed off on the verification.

## Scope boundaries

This protocol does not check 800 historical binary checkpoint RDS files, verify all raw per-origin forecast trajectories byte-for-byte, prove unconditional or conditional coverage guarantees, or evaluate performance on real production data. Independent researchers may expand the protocol, but must distinguish additions from the core checks above.

**Manuscripts, PDF figures and rendered plots must not be added to this GitHub repository.**
