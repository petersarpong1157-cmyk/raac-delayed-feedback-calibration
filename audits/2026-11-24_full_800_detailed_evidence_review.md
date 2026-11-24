# Archived Detailed Evidence — Complete 800-Run RAAC Reproduction Audit

**Archive date:** 24 November 2026  
**Evidence source:** Three original audit files uploaded by the author and preserved under `audits/full_800_evidence/`, retaining CRLF line endings.

## Files

- [replication_checks.csv](full_800_evidence/replication_checks.csv): 800 complete scenario-replication test records, each with seed, pass flag, method and regime numerical errors, run duration and optional failure message
- [input_md5.csv](full_800_evidence/input_md5.csv): MD5 manifest of 13 input files locked for the author's local Windows rerun
- [session_info.txt](full_800_evidence/session_info.txt): R runtime and package environment

## Record-by-record CSV checks

The full CSV was examined programmatically, not just its printed console summary.

| Verification | Result |
|---|---|
| Total records | **800** |
| Passed records | **800** |
| Failed records | **0** |
| Duplicate (scenario, replication) keys | **0** |
| Number of scenarios | **4** |
| Replications per scenario | **200** (complete 1–200 in each) |
| Seed mapping | **30261123 + replication** for all 800 rows |
| Missing seeds, flags, or numerical error values | **0** |
| Nonempty failure messages | **0** |
| Maximum method-level error | **5.6843418860808e-14** |
| Maximum regime-level error | **6.66133814775094e-16** |
| Maximum permitted absolute error | **1e-10** |
| Sum of recorded run durations | **934.25 seconds** (excludes process startup and other overhead) |

### By volatility scenario

| Scenario | Valid passes | Maximum method-level error | Maximum regime-level error |
|---|---:|---:|---:|
| Gradual_Volatility_Increase | 200 | 5.684342e-14 | 6.661338e-16 |
| Stable | 200 | 5.684342e-14 | 6.661338e-16 |
| Sudden_Volatility_Increase | 200 | 5.684342e-14 | 6.661338e-16 |
| Volatility_Reversal | 200 | 5.684342e-14 | 6.661338e-16 |

## Input integrity and environment

The 13-line input manifest contains distinct file paths and valid 32-character hexadecimal MD5 checksums for the frozen configuration, scenarios, final seed schedule, archived benchmark metrics and subgroups, and eight original R source files. The audit script checks these against local copies across successive batch runs. The manifest is **local input-locking evidence**, not an independent byte-for-byte checksum attestation of each GitHub file from another platform.

Runtime: **R 4.5.2**, Windows 11 x64 build 26200, **data.table 1.18.6.1**, LAPACK 3.12.1.

## Archived file preservation

The supplied files were copied to GitHub as text with the original Windows CRLF format preserved. GitHub retrieval confirmed file sizes **74,517**, **1,042**, and **690** bytes respectively, matching the originals.

## Supported reproducibility claim

The author's full frozen-code numerical rerun from a fresh GitHub clone **passed all 800 replications**, and the saved detailed audit CSV supports the reported result. The seven archived statistical reprocessing tests and four-scenario preliminary rerun also passed separately.

## Remaining limits

These are **author-executed** checks rather than third-party independent replication or cross-platform CI. They verify simulation summary outputs against the archived benchmark to numerical tolerance; they do **not** reconstruct or byte-compare the 800 historical checkpoint RDS files, verify every underlying trajectory/forecast row independently, or establish a real-world empirical predictive advantage. The manuscript and rendered figures remain intentionally excluded.
