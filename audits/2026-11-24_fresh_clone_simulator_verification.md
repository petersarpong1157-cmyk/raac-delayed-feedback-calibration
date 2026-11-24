# Fresh-Clone Frozen Simulator Verification — 24 November 2026

## Provenance

This report records **console output provided by the author** from a clean GitHub clone on Windows, using Rscript --vanilla to execute `scripts/VERIFY_FROZEN_SIMULATOR.R`. The test was executed by the author, not by GitHub Actions or the assistant. The exact output in this record is transcribed from the author's console message. No raw automated log artifact was uploaded.

## Execution

- Git repository: `https://github.com/petersarpong1157-cmyk/raac-delayed-feedback-calibration`
- Clone location: `C:\Users\peter\AppData\Local\Temp\RtmpYtOjzD/raac-simulator-verification`
- Script: `scripts/VERIFY_FROZEN_SIMULATOR.R`
- Invocation: `Rscript.exe --vanilla <script path>`
- Exit status: **0**
- Scenario runs: **4** (one per scenario, replication 1, same final seed `30261124`)
- Method-level rows checked: **28**
- Regime-level rows checked: **56**

## Scenarios regenerated

1. Gradual_Volatility_Increase — replication 1, seed 30261124
2. Stable — replication 1, seed 30261124
3. Sudden_Volatility_Increase — replication 1, seed 30261124
4. Volatility_Reversal — replication 1, seed 30261124

## Maximum absolute differences against the archive

| Variable | Max absolute difference |
|---|---:|
| method_n | 0 |
| method_mean_score | 4.618528e-14 |
| method_coverage | 5.551115e-16 |
| method_mean_width | 4.618528e-14 |
| method_minimum_regime_coverage | 5.551115e-16 |
| method_worst_regime_shortfall | 4.996004e-16 |
| regime_regime_n | 0 |
| regime_regime_coverage | 5.551115e-16 |

All numerical differences were below the script's `1e-10` tolerance.

## Verification checks

1. Four final-seed scenarios regenerated — **TRUE**
2. Method-level rows and keys align — **TRUE**
3. Regime-level rows and keys align — **TRUE**
4. Method-level values match archived results — **TRUE**
5. Regime-level values match archived results — **TRUE**

Reported terminal message:

```text
PASS: Four single-replication scenarios reproduced against archive.
This does not reproduce all 800 replications.
Simulator verification exit status: 0
```

A warning noted that `data.table` was built under R 4.5.3; it did not stop execution.

## What this establishes

The user executed the **frozen simulation code** from a fresh clone to recreate four specified 800-benchmark runs and showed near-exact agreement with the archived method-level and regime-level results.

## What this does not establish

- It is **not** a fresh rerun of all 800 scenario-replication runs.
- It does **not** verify every original checkpoint RDS file from a GitHub clone.
- It is **not** independent external replication or cross-platform CI.
- It does **not** establish real-world generalizability or conditional-coverage guarantees.
- The result is distinct from the separate seven-check GitHub statistical CSV recomputation audit.
