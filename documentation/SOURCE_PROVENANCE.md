# Source Provenance and Reproduction Scope

## What is actually present

Eight files in `src/` contain 16 R function definitions recovered from the previously archived `exact_method_implementations.txt` extraction. Their original source filenames were:

1. `frozen_generator_function.R`
2. `point_forecast_functions.R`
3. `expert_calibration_functions.R`
4. `RAAC_frozen_engine.R`
5. `aci_comparator_functions.R`
6. `simulation_runner_function.R`
7. `frozen_scoring_functions.R`
8. `benchmark_replication_function.R`

The added three-line comments identify their extraction provenance. They are not the same byte-for-byte files as the original frozen files, and the source package has **not** been revalidated from a fresh clone. Users should compare these definitions against the archived originals, and the original independent rerun evidence should not be treated as a test of the GitHub clone.

## External runtime configuration dependencies

Some functions expect values previously set by execution scripts: `alpha43`, `global_window43`, `regime_window43`, `expert_names43`, `experts37`, `qcols37`, `target_alpha45`, `gamma45`, `min_alpha45`, `max_alpha45`, `window45`, and `expected_methods`. The original ACI scripts verify `min_alpha45=0.02`, `max_alpha45=0.30`, `gamma45=0.01`, `target_alpha45=0.10`, and `window45=100`.

The immutable generator configuration RDS, actual scenario table, 800-run final seed table, results CSVs, and original execution drivers are still unavailable in this repository. The visualization script uses a hard-coded Windows workstation path.

## Verified history on author's workstation

- 800 checkpoint checksums previously matched.
- Statistical summaries reran in a clean R process, maximum numerical difference approximately `5.33e-14`.
- One benchmark replication for each scenario reran in four separate clean R processes and matched corresponding archived outputs.
- A sudden-shift trajectory was separately recaptured with the frozen engine and audited against its original checkpoint.

The public repository has **not** independently rerun this verification.

## Excluded by author request

No manuscript, figures, rendered PDFs, or intermediate illustration exports are published here.

## Future reproducibility milestones

Upload and independently test the original benchmark configuration, scenario table, seed table, result tables, portable reproduction scripts and a complete release checksum manifest. Original 800 checkpoint files may be provided through a separate archival dataset release if necessary.

No claim of a published journal article or confirmed DOI is made.
