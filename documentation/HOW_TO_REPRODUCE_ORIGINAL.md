# Reproducing the RAAC statistical analysis

Requires R and the data.table package.

From the top level of the release package, run:

```sh
Rscript --vanilla REPRODUCE_ANALYSIS.R
```

The script uses archived 800-replication benchmark
CSV outputs and verifies the seven-method statistics,
paired contrasts, and regime coverage summaries.

A successful run writes its reports to:

`step66_analysis_reproduction/`

This reproduces statistical summaries only.
It does not regenerate the 800 simulations.

The original Step 66 script is retained as a
historical backup and should not be executed.