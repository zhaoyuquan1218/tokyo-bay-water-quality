source("renv/activate.R")
source("R/utils.R")
cfg <- read_config()
q <- utils::read.csv("outputs/tables/record_qc.csv", stringsAsFactors = FALSE)
g <- utils::read.csv("data/processed/regional_quarterly.csv", stringsAsFactors = FALSE)
a <- utils::read.csv("outputs/tables/annual_summary.csv", stringsAsFactors = FALSE)
t <- utils::read.csv("outputs/tables/seasonal_trends.csv", stringsAsFactors = FALSE)
assert(nrow(q) == 4920L && nrow(g) == 4920L, "Unexpected QA or full-grid dimensions.")
assert(nrow(a) == 1230L && nrow(t) == 30L, "Unexpected summary dimensions.")
assert(sum(is.finite(g$value)) == sum(q$eligible), "Eligible records do not reconcile to grid.")
assert(!anyDuplicated(g[c("region", "layer", "year", "quarter", "variable")]), "Duplicated output grid.")
assert(all(t$status == "estimated_descriptive") && all(is.finite(t$slope_per_year)), "Invalid trend results.")
assert(all(t$p_bh >= t$p_value - 1e-12), "Multiplicity adjustment inconsistent.")
assert(all(t$ci_low <= t$slope_per_year & t$ci_high >= t$slope_per_year), "Invalid confidence intervals.")
assert(all(is.na(a$annual_mean[a$n_quarters < 4])), "Incomplete annual means were not withheld.")
# Independently recompute one annual mean directly from the workbook, bypassing the QA aggregation.
d <- readxl::read_excel(file.path("data-raw", cfg$source$file), sheet = "Combined_Data")
i <- d[[1]] == "North" & d[[3]] == 1981
expected <- mean(d[[6]][i])
observed <- a$annual_mean[a$region == "North" & a$year == 1981 & a$variable == "DOC"]
assert(isTRUE(all.equal(expected, observed, tolerance = 1e-12)), "Independent annual mean check failed.")
for (p in c("annual_doc", "data_quality", "seasonal_trends")) {
  path <- file.path("outputs/figures", paste0(p, ".png"))
  con <- file(path, "rb"); sig <- readBin(con, "raw", 8L); close(con)
  assert(identical(as.integer(sig), c(137L, 80L, 78L, 71L, 13L, 10L, 26L, 10L)), "Invalid PNG output.")
  assert(file.info(path)$size > 10000, "Unexpectedly small image.")
}
message("Output reconciliation, independent annual mean and PNG checks passed.")
