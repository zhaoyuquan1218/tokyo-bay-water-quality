verify_checksum <- function(path, expected) {
  assert(file.exists(path), paste("Missing input:", basename(path)))
  assert(identical(unname(tools::md5sum(path)), expected),
         "Source checksum mismatch: retain the file for review; do not analyse a changed release.")
  invisible(path)
}

acquire_source <- function(config, offline = FALSE) {
  s <- config$source
  path <- file.path("data-raw", s$file)
  if (!file.exists(path)) {
    assert(!offline, "Offline mode: download the pinned public workbook first.")
    dir.create("data-raw", showWarnings = FALSE)
    tmp <- tempfile(tmpdir = "data-raw", fileext = ".xlsx")
    on.exit(unlink(tmp), add = TRUE)
    utils::download.file(s$url, tmp, mode = "wb", quiet = TRUE)
    verify_checksum(tmp, s$checksum)
    assert(file.rename(tmp, path), "Cannot move verified download into data-raw.")
  }
  verify_checksum(path, s$checksum)
  path
}

read_published <- function(path, config) {
  d <- as.data.frame(readxl::read_excel(path, sheet = config$source$sheet,
                                      .name_repair = "minimal"))
  meta <- c("Region", "Model period", "Analysis year", "Quarter", "Actual sampling date")
  assert(identical(enc2utf8(names(d)), enc2utf8(c(meta, config$variables$source_header))),
         "Workbook schema or units changed. Review the data contract before continuing.")
  names(d) <- c("region", "model_period", "year", "quarter", "sample_date", config$variables$variable)
  assert(!anyNA(d$region) && all(d$region %in% c("North", "Central", "South")), "Unrecognised source region.")
  d$region[d$region == "Central"] <- "Center"  # Explicit alias to approved mapping.
  year <- strict_numeric(d$year)
  q <- strict_numeric(sub("^Q", "", trimws(d$quarter)))
  assert(all(is.finite(year) & year == floor(year) & year >= config$analysis["start_year"] &
               year <= config$analysis["end_year"]), "Invalid analysis year.")
  assert(all(is.finite(q) & q == floor(q) & q %in% 1:4), "Invalid quarter.")
  d$year <- as.integer(year)
  d$quarter <- as.integer(q)
  d$model_period <- as.Date(d$model_period, tz = "UTC")
  d$sample_date <- as.Date(d$sample_date, tz = "UTC")
  expected <- as.Date(sprintf("%d-%02d-01", d$year, 3L * d$quarter))
  assert(!anyNA(d$model_period) && all(d$model_period == expected), "Model-period/year/quarter mismatch.")
  assert(!anyNA(d$sample_date), "Unparseable actual sampling date.")
  d$layer <- "surface"
  d$source_row <- seq_len(nrow(d)) + 1L
  d$record_id <- paste0("zenodo21798408:Combined_Data:", d$source_row)
  d$time_index <- 4L * (d$year - config$analysis["start_year"]) + d$quarter
  long <- lapply(seq_len(nrow(config$variables)), function(i) {
    v <- config$variables[i, ]
    x <- d[, c("record_id", "source_row", "region", "layer", "model_period", "year", "quarter", "sample_date", "time_index")]
    x$variable <- v$variable
    x$unit <- v$unit
    x$raw_value <- as.character(d[[v$variable]])
    x
  })
  do.call(rbind, long)
}
