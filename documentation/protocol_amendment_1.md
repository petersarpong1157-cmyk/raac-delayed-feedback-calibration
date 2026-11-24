# RANF Evaluation Protocol Amendment 1

## Reason for amendment
Replications 1 and 2 under the previous seed
schedule were used in structural verification.

## Change
Replace the previous replication seeds with
30261124 through 30261323 inclusive.

## Unchanged design
Four simulation scenarios.
200 replications per scenario.
60 origins and 60 sector-size groups.
Training/calibration/evaluation: 24/12/24.
Seven comparison methods.
Frozen RAAC eta=0.10, scale=20, cap=5.
Cohort-level ACI gamma=0.01.
Nominal interval coverage target=90%.
Primary endpoint: mean interval score.
Primary contrast: RAAC minus Fixed Global.
Paired replication-level confidence intervals.

## Reason for keeping common scenario seeds
Matched seeds support paired scenario
comparisons with shared random-number streams.

## Scientific restrictions
No methodological parameters may be retuned
using the resulting benchmark performance.
All seven methods must be reported.
Negative and inconclusive results must be
retained in the final research record.

## Status
Amendment recorded before benchmark execution.
No new benchmark outcomes examined.