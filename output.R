# Stage 3: machine-readable statistics and reproducible scientific figures.
write_table(annual, "outputs/tables/annual_summary.csv")
write_table(models$trends, "outputs/tables/seasonal_trends.csv")
write_table(models$residuals, "outputs/tables/model_residuals.csv")
write_table(comparisons, "outputs/tables/regional_comparisons.csv")
make_figures(annual, summarise_qc(qc), models$trends)
