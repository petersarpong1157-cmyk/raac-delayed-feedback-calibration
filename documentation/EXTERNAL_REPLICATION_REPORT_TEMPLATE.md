# Independent External Replication Report — Template

> **Blank template. Not an external certification.** Complete only after independently running the specified RAAC code. Do not present placeholder fields as observed results.

## 1. Reviewer and execution provenance

- Reviewer name:
- Organization / position:
- Contact (optional, with consent):
- Reviewer ORCID (optional):
- Date(s) of execution:
- Relationship to study author or research team:
- Statement confirming independence (or describing prior involvement):
- Conflicts of interest / relevant funding:
- Git repository URL:
- Git commit SHA (`git rev-parse HEAD`):
- Git working tree clean before execution? Yes / No (details):
- Operating system and architecture:
- R version:
- `data.table` version:
- Additional dependencies or environmental differences:

## 2. Commands, evidence and changes

- Exact clone and installation commands:
- Exact statistical test command, exit code, log filename:
- Exact full simulator command(s), exit code(s), log filename(s):
- Number of batches and interruptions:
- Changes to original code, configuration, seeds, reference data or test scripts? None / Describe precisely:
- Manual interventions / warnings / errors:
- Evidence folder name or stable link:

## 3. Test A — archived CSV statistics

| Check | PASS / FAIL / NOT RUN | Supporting evidence |
|---|---|---|
| Input dimensions and keys | | |
| Seven method summary | | |
| Primary paired contrasts | | |
| Secondary paired contrasts | | |
| Regime coverage table | | |
| Subgroup observation counts | | |
| Marginal/subgroup coverage reconciliation | | |

- `github_analysis_audit.csv` attached?:
- `github_numerical_errors.csv` attached?:
- Maximum absolute error observed:
- Statistical reprocessing exit code:
- Test A outcome: PASS / PASS WITH QUALIFICATIONS / FAIL / INCOMPLETE

## 4. Test B — frozen simulator 800/800

| Scenario | Passed / 200 | Failures / missing | Maximum method error | Maximum regime error |
|---|---:|---:|---:|---:|
| Gradual_Volatility_Increase | | | | |
| Stable | | | | |
| Sudden_Volatility_Increase | | | | |
| Volatility_Reversal | | | | |
| **Total** | **/800** | | | |

- Replication result rows:
- Unique scenario/replication keys:
- Seeds checked against frozen seed schedule?:
- All `passed == TRUE`?:
- Missing or nonfinite values?:
- Any nonblank `error_message`?:
- Maximum method error:
- Maximum regime error:
- Tolerance applied (default `1e-10`):
- `input_md5.csv` attached?:
- `session_info.txt` attached?:
- `replication_checks.csv` attached?:
- Final `--status` output:
- Test B outcome: PASS / PASS WITH QUALIFICATIONS / FAIL / INCOMPLETE

## 5. Verification notes

Discuss any environment differences, tolerance-sensitive results, computational failures, or deviations. Distinguish archived-statistics agreement from rerunning simulated data and from historical binary checkpoint comparison.

## 6. Scope and limitations

State whether this was performed using independent computing resources. Note that the protocol checks archived synthetic summary reproduction, not byte-for-byte historical checkpoint equality, real-world predictive accuracy, or conditional coverage guarantees. If additional verification was performed, describe it separately.

## 7. Final conclusion

Select **one**:

- [ ] **PASS** — all required checks met without material deviations
- [ ] **PASS WITH QUALIFICATIONS** — core checks passed; qualifications explained
- [ ] **FAIL** — material discrepancies or integrity problems observed
- [ ] **INCOMPLETE** — evidence or testing insufficient for a conclusion

**Reasoned conclusion (include factual support):**

> [Independent reviewer to complete]

**Reviewer name:**  
**Signature or explicit authenticated approval:**  
**Date:**  
**Permission to post report and audit files publicly:** Yes / No / Restricted (details)

This report is a third-party reproduction record **only if actually completed by the independent reviewer**. The repository author should not sign on the reviewer's behalf.
