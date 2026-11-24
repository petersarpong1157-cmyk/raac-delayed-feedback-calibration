# Publish the RAAC v1.0.0 GitHub Snapshot to Zenodo

**Prepared for release, not yet published**. The repository already includes MIT `LICENSE`, `CITATION.cff`, `.zenodo.json`, release notes, all 800 frozen benchmark audit records, and no manuscript or rendered figures.

## 1. Enable GitHub archiving in Zenodo **before** publishing the release

1. Sign in at https://zenodo.org/ and connect the GitHub account `petersarpong1157-cmyk` if needed.
2. Open https://zenodo.org/account/settings/github/ .
3. Use **Sync now** if the repository does not appear.
4. Find `raac-delayed-feedback-calibration` and enable its Zenodo integration toggle.
5. Confirm the repository is enabled.

Zenodo official instructions: https://help.zenodo.org/docs/github/enable-repository/

## 2. Create the first GitHub Release

1. Visit https://github.com/petersarpong1157-cmyk/raac-delayed-feedback-calibration/releases/new
2. **Choose a tag:** `v1.0.0` (create a new tag from `main`).
3. **Release title:** `RAAC Frozen Benchmark v1.0.0 — Code, Data & Reproduction Evidence`
4. **Description:** Paste the content of `documentation/RELEASE_NOTES_v1.0.0.md` from the current repository.
5. **Target:** `main`, after the MIT license and `.zenodo.json` are committed.
6. Use a **normal public release**, not a draft or pre-release, when ready.
7. Click **Publish release**.

No manual ZIP attachment is necessary for the standard GitHub–Zenodo archive integration: Zenodo archives the source snapshot corresponding to the release tag. The tag and release must be published after enabling the repository in Zenodo.

## 3. Verify the Zenodo record

1. Return to the Zenodo GitHub integrations page and locate the ingested release record.
2. Confirm title, creator and ORCID, **Software** resource type, `v1.0.0`, open access and **MIT** license.
3. Check the archived files and make sure there is **no manuscript, publication figure or rendered PDF**.
4. Record the actual version DOI and concept DOI that Zenodo generates. **Do not invent or prefill DOIs.**
5. If the release ingestion fails, consult the Zenodo error details and correct metadata before publishing another release.

Official Zenodo archiving instructions: https://help.zenodo.org/docs/github/archive-software/github-upload/

## 4. Add the confirmed DOI to the repository

After verifying the DOI on Zenodo, add its citation to `README.md` and release documentation. The existing `.zenodo.json` has priority over `CITATION.cff` for Zenodo GitHub integration, and both specify the MIT license. `CITATION.cff` is included to support GitHub's citation display.

## Scientific and rights disclosures

- The 800/800 reproduction audit was performed by the **author** on Windows; independent third-party external replication has not been completed.
- Numerical outputs matched archived synthetic benchmark summaries at tolerance `1e-10`. These results do not imply empirical validation or distribution-free conditional coverage.
- The original 800 RDS historical checkpoints are not in the GitHub snapshot.
- MIT licensing applies to the author's rights in the included software and associated documentation; do not represent it as conveying third-party rights over externally sourced materials.
- The repository and Zenodo snapshot should **not** include the research manuscript or rendered figures.
