# Validation record

Validation date: **2026-11-11 (Asia/Tokyo)**. Host: Windows, R 4.5.3 (ucrt). Commands were executed from the project root using `Rscript --vanilla`. This record describes actual local validation; it does not certify the original doctoral model suite or every operating system.

| Check | Command or evidence | Outcome |
|---|---|---|
| Archival identity | Downloaded workbook compared with archive MD5 | Matched `ef0874d94621c2fdb947bb3482a1d9d8` |
| Fresh R acquisition | `Rscript --vanilla scripts/check_acquisition.R` | Fresh HTTPS download and checksum passed in isolated scratch directory |
| Full workflow | `Rscript --vanilla run_all.R --offline` | All four stages completed; 4,920 retained source measurements, 4,880 eligible |
| Automated tests | `Rscript --vanilla tests/testthat.R` | 13 test blocks, 43 expectations passed; no failed or skipped tests in final run |
| Independent environment | `Rscript --vanilla scripts/verify_environment.R` | 45 locked packages restored into an initially empty separate library; fresh subprocesses verified every package resolves there; workflow, tests and output checks passed |
| Numerical/output checks | `Rscript --vanilla scripts/validate_outputs.R` | Full grid 4,920 rows; annual summary 1,230 rows; trend summary 30 rows; eligible counts reconcile; incomplete annual means remain missing |
| Independent reference | North DOC 1981 annual mean recalculated directly from workbook | Agreed within 1e-12 |
| Covariance reference | Synthetic intercept-only regression with genuine temporal gaps | Agreed with explicit pairwise Bartlett covariance calculation within 1e-12 |
| Missingness and duplicates | Unit tests with labelled synthetic invalid/missing/duplicate values | Flags, quarantine, no imputation, layer separation and equal-station aggregation verified |
| Known seasonal signal | Synthetic trend plus quarterly effects and seeded noise | Per-year slope recovered within 0.001 |
| Source schema | Exact headers/units plus deliberately changed header | Correct source accepted; changed schema rejected |
| Repeated execution | `Rscript --vanilla scripts/check_reproducibility.R` | Identical MD5 hashes for all 11 generated grid/table/report/PNG files across sequential runs |
| Figures | All three exported PNGs opened and visually inspected; PNG signatures checked | Marks, labels, unit scales, region shapes/line types, intervals and captions present without clipping |
| Original-code reuse | `Rscript --vanilla scripts/audit_existing_sources.R` | Two helper bodies/arguments match original parsed definitions; six-station file copied unchanged |

The original doctoral source scan found 300 R scripts under `R/`, `scripts/` and `tests/`; 155 matched an absolute-drive-path or `setwd()` pattern. This is a pattern-based reproducibility screen, not a complete semantic audit. The eight selected source-file hashes are in `source-code-inventory.csv`.

## Validation issues resolved during development

The first separate-library harness restored packages correctly but selected a nested renv library path in its subprocess. The harness now sets the fresh library explicitly and asserts that every locked package resolves there. A version-check comparison was also corrected to compare exact DESCRIPTION versions, preserving CRAN version strings such as `1.1-3`.

An early product-hash check overlapped another workflow writing the same output directory. After serializing workflow execution, all 11 product hashes matched. Concurrent writes to one output directory are unsupported. These were verification-harness issues; scientific input values and regression equations were not altered to pass checks.

## Remaining limitations

- The host emitted startup warnings because its requested `C.UTF-8` locale was unavailable. Source Unicode unit headers were explicitly decoded and checked; all final tests and output checks passed. Cross-platform font and binary-image identity are not asserted.
- The 2011 quarterly conflicts in the archived release remain unresolved. Source rows are preserved and quarantined. No scientific correction is inferred.
- Upstream cleaning, original laboratory QC, units in private raw exports, station-level ingestion and bottom observations are not independently validated by the public workflow.
- No TAF/icesTAF environment, full VAR/FEVD reproduction, M0 calibration or mass-balance changes were performed. The original PhD model tests were not rerun because none of those files was changed.
- GitHub Actions configuration is supplied. Its actual remote execution status is reported separately at delivery; local success alone is not evidence of hosted CI success.
- Code licensing remains an author decision. The CC BY 4.0 dataset license is verified independently.
