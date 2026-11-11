# Adapted from the author's PhD R/02_extract_monitoring_data.R; see docs/code-provenance.md.
strict_numeric <- function(x) {
  z <- iconv(as.character(x), from = "", to = "UTF-8", sub = "")
  z <- trimws(z)
  z[z %in% c("", "NA", "NaN", "N/A", "#VALUE!")] <- NA_character_
  numeric_pattern <- "^[+-]?(([0-9]+([.][0-9]*)?)|([.][0-9]+))([eE][+-]?[0-9]+)?$"
  out <- rep(NA_real_, length(z))
  valid <- !is.na(z) & grepl(numeric_pattern, z)
  out[valid] <- suppressWarnings(as.numeric(z[valid]))
  out
}

safe_mean_monitoring <- function(x) {
  finite <- is.finite(x)
  if (!any(finite)) return(NA_real_)
  mean(x[finite])
}

assert <- function(ok, message) {
  if (!isTRUE(ok)) stop(message, call. = FALSE)
}

require_columns <- function(data, columns, context = "data") {
  missing <- setdiff(columns, names(data))
  assert(!length(missing), paste(context, "missing columns:", paste(missing, collapse = ", ")))
}

write_table <- function(x, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(x, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
}

decode_unicode <- function(x) {
  # Configuration stays ASCII to work on hosts with an invalid UTF-8 locale.
  vapply(x, function(z) {
    m <- gregexpr("\\\\u[0-9a-fA-F]{4}", z, perl = TRUE)
    hits <- regmatches(z, m)[[1]]
    if (length(hits)) regmatches(z, m) <- list(vapply(hits, function(h)
      intToUtf8(strtoi(substring(h, 3), 16L)), ""))
    enc2utf8(z)
  }, "", USE.NAMES = FALSE)
}

read_config <- function() {
  a <- utils::read.csv("config/analysis.csv", stringsAsFactors = FALSE)
  v <- utils::read.csv("config/variables.csv", stringsAsFactors = FALSE)
  v$source_header <- decode_unicode(v$source_header)
  list(analysis = setNames(as.numeric(a$value), a$setting), variables = v,
       source = utils::read.csv("config/source.csv", stringsAsFactors = FALSE))
}

load_modules <- function() {
  for (p in c("readxl", "ggplot2"))
    assert(requireNamespace(p, quietly = TRUE), paste("Missing package", p, "- run scripts/setup.R"))
  for (f in c("acquire.R", "qc.R", "statistics.R", "figures.R")) source(file.path("R", f))
}
