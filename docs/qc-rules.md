# Quality rules and audit trail

## Grain and contracts

The public input grain is a deposited region-model-period record, reshaped into one record per variable. The analytical key is `(region, layer, analysis year, quarter, variable)`. A `record_id` identifies the Zenodo record, worksheet and physical Excel row; it is retained even when a record is ineligible. `source_row=2` is the first data row after the worksheet header. `raw_value` is the cell value returned by `readxl`, not an image of the original instrument record.

Exact column names, including unit labels, must match `config/variables.csv`. Numeric values are parsed strictly: qualifiers such as `<0.1` do not become quantified observations. There are no automatic unit conversions. Source `PSU` is retained as a source label rather than reinterpreted as a new salinity standard. pH scale and original laboratory methods are not established by the release.

| Check | Rule | Treatment |
|---|---|---|
| Source identity | Match archive-provided MD5 | Stop on mismatch |
| Schema/units | Exact documented headers | Stop on incompatible workbook |
| Region | North, Central, South; explicit Central to Center alias | Stop on unknown label |
| Time | Integer 1981-2021 year; Q1-Q4; model date equals March/June/September/December first day | Stop on inconsistency |
| Actual date | Valid date; distinct from campaign model period | Retain without reassignment |
| Missing | Empty, NA, NaN, N/A, #VALUE! | Retain and flag; ineligible |
| Parsing | Full numeric string required; finite result | Retain and flag; ineligible |
| Units | Match variable contract | Retain and flag; ineligible |
| Domain | Nonnegative concentrations, salinity and depth; pH screening 0-14 | Retain and flag; ineligible |
| Temperature | No undocumented temperature bounds imposed | No range exclusion |
| Duplicate analytical key | Any group with more than one source row | Retain all members; quarantine all |
| Extreme value | Outside Q1 minus 3 IQR to Q3 plus 3 IQR, within region/layer/variable/season; at least 8 eligible records and positive IQR | Review flag only; eligible |
| Analysis grid | All 164 model quarters per region and variable | Unavailable values remain NA |
| Annual mean | Four eligible quarterly values | Otherwise NA with coverage count |

## Findings in the pinned public release

Center worksheet-equivalent records `Combined_Data` Excel rows **286 and 287**, and South rows **450 and 452**, each share a 2011-Q2 analytical key within region. Actual sampling dates are 2011-06-07 and 2011-08-02 in each group. Center and South have no deposited 2011-Q1 key. The evidence does not authorize changing either row to Q1.

These four deposited rows generate 40 duplicate flags across ten variables. All 4,920 source variable records remain in `record_qc.csv`; 4,880 are eligible. The explicit complete grid has 40 missing cells: 20 from absent Q1 source positions and 20 from quarantined Q2 positions. This is a data-quality finding, not a new oceanographic finding. No raw observations were corrected and no archival record was edited.

The workbook README describes a `Quality_Check` worksheet, but that sheet is absent from the downloaded release. Executable checks in this repository do not rely on that description.

The upstream workbook contains no missing measurement cells. That observation alone does not establish whether the upstream cleaning included filling, censor handling or exclusions. This workflow performs no imputation and cannot retrospectively audit undocumented upstream decisions.

## Optional station-export checks

`scripts/audit_station_export.R` accepts one long-format, already station-quarter-level export, with `record_id`, `source_file`, `station_key`, `layer`, `year`, `quarter`, `variable`, `unit`, and `raw_value`. An optional region must agree with the approved mapping. No Excel/raw-field aliases or unknown units are guessed.

Only keys in `config/stations.csv` are accepted. Units must be independently verified before using this adapter. Surface and bottom form separate groups. Multiple records for a station-quarter-variable are quarantined because a replicate-resolution rule has not been authorized. Eligible station means are equally weighted within region, with contributing and expected station counts. No area weighting or missing-station interpolation is applied. This adapter is unit-tested with labelled synthetic fixtures; original raw-export ingestion remains outside the validated public path.
