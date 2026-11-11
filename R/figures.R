make_figures <- function(annual, qc_summary, trends) {
  palette <- c(North = "#0067A0", Center = "#B65F00", South = "#576E24")
  region_levels <- names(palette)
  for (name in c("annual", "qc_summary", "trends")) {
    z <- get(name); z$region <- factor(z$region, levels = region_levels); assign(name, z)
  }
  theme <- ggplot2::theme_minimal(base_size = 12, base_family = "sans") +
    ggplot2::theme(panel.grid.minor = ggplot2::element_blank(),
                   legend.position = "top", plot.title.position = "plot",
                   plot.caption = ggplot2::element_text(hjust = 0, size = 9),
                   axis.title = ggplot2::element_text(size = 11))
  doc <- annual[annual$variable == "DOC", ]
  p1 <- ggplot2::ggplot(doc, ggplot2::aes(year, annual_mean, color = region, shape = region, linetype = region)) +
    ggplot2::geom_line(linewidth = .65, na.rm = FALSE) + ggplot2::geom_point(size = 1.8, na.rm = TRUE) +
    ggplot2::scale_color_manual(values = palette) +
    ggplot2::scale_x_continuous(breaks = c(1981, 1990, 2000, 2010, 2021)) +
    ggplot2::labs(title = "Tokyo Bay dissolved organic carbon", subtitle = "Published regional quarterly series | annual means require all four quarters",
                  x = "Analysis year", y = "DOC (mg C/L)", color = NULL, shape = NULL, linetype = NULL,
                  caption = "Source: Zhao (2026), Zenodo 21798408, CC BY 4.0. No imputation in this workflow.") + theme
  q <- qc_summary
  q$eligible_percent <- 100 * q$n_eligible / q$n_records
  p2 <- ggplot2::ggplot(q, ggplot2::aes(region, variable, fill = eligible_percent)) +
    ggplot2::geom_tile(color = "white", linewidth = .6) +
    ggplot2::geom_text(ggplot2::aes(label = paste0(n_eligible, "/", n_records)), size = 3.4) +
    ggplot2::scale_fill_gradient(low = "#FFFFFF", high = "#9CC6DB", limits = c(0, 100)) +
    ggplot2::labs(title = "Quality and coverage of the published data", subtitle = "Eligible / deposited records; source is already processed",
                  x = NULL, y = NULL, fill = "Eligible (%)",
                  caption = "A complete deposited series does not establish completeness or validity of the original monitoring archive.") + theme
  trends$facet <- paste0(trends$variable, " (", trends$unit, "/year)")
  p3 <- ggplot2::ggplot(trends, ggplot2::aes(region, slope_per_year, color = region, shape = region)) +
    ggplot2::geom_hline(yintercept = 0, color = "#666666", linetype = 2, linewidth = .35) +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = ci_low, ymax = ci_high), width = .15, linewidth = .6) +
    ggplot2::geom_point(size = 2.3) + ggplot2::facet_wrap(~facet, scales = "free_y", ncol = 2) +
    ggplot2::scale_color_manual(values = palette) +
    ggplot2::labs(title = "Season-adjusted linear trends, 1981-2021", subtitle = "Point estimates and approximate 95% HAC intervals (lag 4 quarters)",
                  x = NULL, y = "Slope in the unit shown in each panel", color = NULL, shape = NULL,
                  caption = "Exploratory linear summaries; panel scales differ. Intervals are not simultaneous. See lag-8 sensitivity and BH-adjusted p-values.") + theme +
    ggplot2::theme(legend.position = "none", axis.text.x = ggplot2::element_text(size = 10))
  dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
  plots <- list(annual_doc = p1, data_quality = p2, seasonal_trends = p3)
  for (name in names(plots)) ggplot2::ggsave(file.path("outputs/figures", paste0(name, ".png")),
    plots[[name]], width = 10, height = if (name == "seasonal_trends") 11 else 6,
    dpi = 220, bg = "white")
  invisible(plots)
}
