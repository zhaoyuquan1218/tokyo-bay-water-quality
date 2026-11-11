# Optional development audit of the pre-existing PhD workspace. Read-only.
# Only relative file names, hashes and summary counts are written; no measurements or personal paths.
research <- Sys.getenv("TOKYO_BAY_RESEARCH_ROOT", unset = "..")
selected <- c("R/00_utils.R", "R/01_data_audit.R", "R/02_extract_monitoring_data.R",
              "R/02_prepare_data.R", "R/00_packages.R", "R/cusp/03A_changepoint_analysis.R",
              "scripts/run_data_preparation.R", "config/stations.csv")
if (!all(file.exists(file.path(research, selected)))) stop("Selected PhD sources are unavailable; set TOKYO_BAY_RESEARCH_ROOT.")
manifest <- data.frame(source_file = selected, md5 = unname(tools::md5sum(file.path(research, selected))),
                       treatment = c("helper inspected", "inventory inspected", "two helpers reused verbatim",
                         "quarterly-grid approach inspected", "dependencies inspected", "seasonal OLS approach adapted",
                         "absolute-path issue inspected", "mapping copied unchanged"))
dir.create("docs", showWarnings = FALSE)
utils::write.csv(manifest, "docs/source-code-inventory.csv", row.names = FALSE)

# Evaluate only the two literal function definitions, not the source script and its source() calls.
tree <- parse(file.path(research, "R/02_extract_monitoring_data.R"))
env <- new.env(parent = baseenv())
for (f in c("strict_numeric", "safe_mean_monitoring")) {
  found <- Filter(function(e) is.call(e) && identical(e[[1]], as.name("<-")) &&
                    identical(e[[2]], as.name(f)), as.list(tree))
  stopifnot(length(found) == 1L)
  eval(found[[1]], envir = env)
}
project <- new.env(parent = baseenv()); sys.source("R/utils.R", envir = project)
for (f in c("strict_numeric", "safe_mean_monitoring"))
  stopifnot(identical(body(env[[f]]), body(project[[f]])), identical(formals(env[[f]]), formals(project[[f]])))
message("Two reused helper definitions match the inspected originals; station map MD5: ",
        unname(tools::md5sum("config/stations.csv")))

# Bounded inventory of the original code tree, without importing code or data.
files <- unlist(lapply(c("R", "scripts", "tests"), function(d)
  list.files(file.path(research, d), pattern = "[.][Rr]$", recursive = TRUE, full.names = TRUE)))
lines <- unlist(lapply(files, function(p) readLines(p, warn = FALSE, encoding = "UTF-8")), use.names = FALSE)
path_files <- sum(vapply(files, function(p) any(grepl("[CDEF]:[/\\\\]|setwd\\(",
  readLines(p, warn = FALSE, encoding = "UTF-8"))), logical(1)))
counts <- data.frame(metric = c("existing_R_scripts", "R_scripts_with_absolute_path_or_setwd_pattern"),
                     value = c(length(files), path_files))
utils::write.csv(counts, "docs/source-audit-counts.csv", row.names = FALSE)
message("Read-only source audit completed.")
