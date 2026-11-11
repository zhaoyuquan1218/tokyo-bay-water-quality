args <- commandArgs(trailingOnly = TRUE)
if (length(setdiff(args, "--offline"))) stop("Usage: Rscript --vanilla run_all.R [--offline]", call. = FALSE)
if (!file.exists("config/source.csv")) stop("Run from the project root.", call. = FALSE)
if (file.exists("renv/activate.R")) source("renv/activate.R")
source("R/utils.R")
load_modules()
config <- read_config()
offline <- "--offline" %in% args
for (stage in c("data.R", "model.R", "output.R", "report.R")) {
  message("Running ", stage)
  source(stage, local = TRUE)
}
manifest <- data.frame(input_file = config$source$file, md5 = unname(tools::md5sum(path)),
                       r_version = as.character(getRversion()), records = nrow(qc),
                       eligible = sum(qc$eligible), stringsAsFactors = FALSE)
write_table(manifest, "outputs/run_manifest.csv")
writeLines(capture.output(sessionInfo()), "outputs/sessionInfo.txt")
message("Completed. See outputs/report.md")
