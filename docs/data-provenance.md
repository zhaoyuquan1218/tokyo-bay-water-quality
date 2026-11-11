# Data provenance

The primary publication's [data availability statement](https://aslopubs.onlinelibrary.wiley.com/doi/10.1002/lno.70503) points to [Zenodo record 21798408](https://doi.org/10.5281/zenodo.21798408). Its API metadata was inspected on 2026-11-11: access `open`, license `cc-by-4.0`, creator Zhao, Yuquan, publication date 2026-08-05. File name, URL, sheet and archive checksum are pinned in `config/source.csv`. The downloaded workbook is 116,218 bytes and matches `md5:ef0874d94621c2fdb947bb3482a1d9d8`.

The release is titled *Processed quarterly water-quality dataset for dissolved organic carbon variance attribution in Tokyo Bay, 1981-2021*. It supplies 492 deposited records, with 164 rows labelled for each region. It is already processed and is not an original instrument-level dataset. The workflow reads only `Combined_Data`; region-specific worksheets are not concatenated, avoiding double counting.

The workbook credits Japan's Ministry of the Environment Water Environment Integrated Information Site as its original source. The doctoral workspace separately contains read-only annual surface and bottom CSVs and processed station exports. Neither those local observations nor their absolute paths are published by this project. The existing source code records unresolved units and field-pair conflicts; those uncertainties are not silently resolved using the public workbook's unit labels.

The input header contract retains the source's physical units. Source names use Unicode unit symbols; the ASCII configuration encodes these as `\uXXXX` and decodes them explicitly to handle Windows locale limitations. Output labels use ASCII unit equivalents (`mg C/L`, `ug/L`, `degC`, etc.) without changing values.

`record_qc.csv`, the complete quarterly grid, summaries and figures are derived from this open dataset and retain its attribution. Review/exclusion rules are new, explicit processing steps described in [QC rules](qc-rules.md). No synthetic observations enter the displayed results.

Known metadata issues are the conflicting 2011 quarter keys and the absent `Quality_Check` sheet described in the workbook README. No unpublished inference is used to repair them. The notebook-free analysis record consists of the acquisition code, pinned source contract, retained per-record flags, statistical scripts, tests and generated tables.
