# Code provenance and initial research audit

The existing doctoral workspace was inspected read-only before implementation. The Git worktree at its root had no configured remote and all listed research files were untracked. Therefore a separate nested project was established for the single authorized GitHub repository. No research file was overwritten, deleted or committed from the parent worktree.

## Selected inspected sources

| Existing doctoral source | Evidence and treatment in this project |
|---|---|
| `R/00_utils.R` | Directory, field-validation and numeric-parsing helpers inspected; field checks adapted |
| `R/01_data_audit.R` | Explicit 1981-2021 annual-file inventory and surface/bottom split inspected |
| `R/02_extract_monitoring_data.R` | Source-field pairing, conflict audit, derived-variable caveats and equal-station regional aggregation inspected |
| `R/02_prepare_data.R` | Quarter normalization, complete time grid, missingness and seasonal-anomaly preparation inspected |
| `R/00_packages.R` | DSEM workflow dependencies and automatic installation inspected |
| `R/cusp/03A_changepoint_analysis.R` | Seasonal linear regression and lag-4 HAC inference inspected; regression structure adapted without breakpoint selection |
| `scripts/run_data_preparation.R` | Personal default raw-data path identified; no such fallback is used here |
| `config/stations.csv` | Approved six-station map copied unchanged |

`strict_numeric()` and `safe_mean_monitoring()` in `R/utils.R` are reused verbatim from `R/02_extract_monitoring_data.R`. The read-only audit script compares their parsed function bodies and arguments to the original definitions, avoiding execution of the source file. Selected source hashes are recorded in [source-code-inventory.csv](source-code-inventory.csv). These are snapshots of inspected files, not claims about the unpublished workspace's complete version history.

The station aggregation function preserves the equal-station concept and layer separation, with stricter duplicate quarantine and explicit contributing/expected station counts. No raw field-pair extraction, unit assumptions, imputation procedure or scientific process-model equation has been silently copied or changed.

## Available research materials inspected

- R modules for extraction, data audits, quarterly preparation, M0 fluxes/calibration/evaluation, DSEM, changepoint analysis and carbon budgets.
- CSV station-layer and regional-quarterly exports, field-conflict logs, source inventories and unit dictionaries; only headers and selected metadata were read for provenance and schema checks.
- Excel monitoring/manual files and extensive generated PNG/PDF figures were identified in the directory inventory. Their full contents were not individually read or validated.
- Existing VAR/FEVD and imputation-diagnostic outputs were identified. This does not establish the validity or reproducibility of those entire original analyses.
- The published Zenodo workbook was downloaded, checksum-verified and inspected in all six worksheets; the analytical path reads `Combined_Data` only.

## Reproducibility risks identified

Personal absolute paths and `setwd()` appear in multiple existing scripts. The original raw-data extraction defaults to a local drive; some upstream CSV unit metadata are undocumented; qualifiers and paired fields require explicit reconciliation; model periods differ from actual sampling dates. Some original package loaders install dependencies automatically. The new public workflow uses relative paths, exact public source headers, explicit setup, a lockfile and retained flags to address the risks within its documented scope.

The inspected doctoral package list includes `dsem`, `dplyr`, `tidyr`, `readr`, `ggplot2`, `purrr`, `stringr`, `tibble`, `tseries` and `patchwork`. This is one workflow's dependency list, not a complete dependency census of every doctoral script. The new project's smaller environment is captured independently in `renv.lock`.

No original M0 equations or parameters were changed. Central `config/parameters_m0.csv` remains in the original research workspace. This empirical portfolio project introduces no M0 parameter registry, calibration or additional DOC/POC state.
