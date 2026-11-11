# Stage 2: descriptive seasonal regression; no process-model calibration.
annual <- annual_summary(quarterly, config$analysis["annual_min_quarters"])
models <- fit_trends(quarterly, config)
comparisons <- regional_comparison(quarterly)
