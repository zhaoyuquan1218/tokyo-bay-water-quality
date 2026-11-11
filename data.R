# Stage 1: acquisition, schema validation and record-level QC.
path <- acquire_source(config, offline = offline)
observations <- read_published(path, config)
qc <- qc_records(observations, config$variables, config$analysis["iqr_multiplier"])
write_table(qc, "outputs/tables/record_qc.csv")
write_table(summarise_qc(qc), "outputs/tables/qc_summary.csv")
quarterly <- complete_grid(qc, config)
write_table(quarterly, "data/processed/regional_quarterly.csv")
