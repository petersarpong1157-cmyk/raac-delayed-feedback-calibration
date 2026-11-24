# Source Provenance and Reproduction Scope

## Original source files

The eight `src/*.R` files currently on GitHub were replaced with **the corresponding original R files uploaded from the frozen study**, rather than the function-definitions reconstructed earlier.

Original filenames:
- `RAAC_frozen_engine.R`
- `frozen_generator_function.R`
- `point_forecast_functions.R`
- `expert_calibration_functions.R`
- `aci_comparator_functions.R`
- `simulation_runner_function.R`
- `frozen_scoring_functions.R`
- `benchmark_replication_function.R`

On receipt, all eight original binary file MD5s matched the author's supplied `source_integrity.csv` or `execution_source_lock.csv`. The uploaded `aci_comparator_functions(1).R` had the same MD5 as `aci_comparator_functions.R`, so the duplicate was not uploaded.

**Important distinction:** GitHub's text-file submission normalizes Windows CRLF line endings to LF. Therefore GitHub blob hashes and MD5 hashes need not match historical original Windows MD5, although the file content was sourced from the originals. The RDS frozen configuration was uploaded as an original binary blob, and its blob SHA was verified independently.

## Added research evidence

- Original frozen configuration: `results/step40_evaluation_design/frozen_simulation_configuration.rds`
- Prespecified four-scenario specification: `results/step40_evaluation_design/prespecified_scenarios.csv`
- Final 800-row independent seed schedule: `results/step52_final_benchmark/independent_replication_seeds.csv`
- 5,600 method-level rows: `results/step54_independent_benchmark/all_replication_metrics.csv`
- 11,200 regime-specific rows: `results/step54_independent_benchmark/all_replication_subgroups.csv`
- 800 original checkpoint hashes, without the checkpoint binary files
- Frozen source integrity records and the original seed amendment

## Runtime configuration dependencies

Source functions rely on execution-script variables such as `alpha43`, `global_window43`, `regime_window43`, `expert_names43`, `experts37`, `qcols37`, `target_alpha45`, `gamma45`, `min_alpha45`, `max_alpha45`, `window45`, and `expected_methods`. The ACI comparison uses `min_alpha45=0.02`, `max_alpha45=0.30`, `gamma45=0.01`, `target_alpha45=0.10`, and `window45=100`, verified from frozen execution scripts in the original study.

## Verification scope

The author's original Windows workstation previously passed:
- Checksums for 800 checkpoint RDS files
- A clean-session statistical reprocessing audit with maximum numerical difference about 5.33e-14
- One archived replication independently rerun for each of the four scenarios
- An additional audited single-replication RAAC weight diagnostic rerun

The public GitHub checkout has **not** independently reproduced the benchmarks. The original comparative statistical summary reference CSVs, the full statistical release manifest for this new distribution, and the 800 checkpoint RDS files have not all been uploaded. Historic verification is evidence about the archived workstation study, not a verified clean GitHub checkout.

No manuscript or figures are hosted, by author request.
