qc_records <- function(x, variables, iqr_multiplier = 3, station_grain = FALSE) {
  require_columns(x, c("record_id", "region", "layer", "year", "quarter", "variable", "unit", "raw_value"))
  assert(nrow(x) > 0L, "Empty observation table.")
  assert(all(x$region %in% c("North", "Center", "South")), "Invalid regional label.")
  assert(all(x$layer %in% c("surface", "bottom")), "Invalid layer.")
  assert(all(is.finite(x$year) & x$year == floor(x$year)), "Invalid year.")
  assert(all(is.finite(x$quarter) & x$quarter %in% 1:4), "Invalid quarter.")
  assert(all(x$variable %in% variables$variable), "Undocumented variable.")
  assert(!anyNA(x$record_id) && all(nzchar(trimws(x$record_id))), "Missing record ID.")
  assert(!anyDuplicated(x[c("record_id", "variable")]), "Record IDs must uniquely identify source rows per variable.")
  j <- match(x$variable, variables$variable)
  raw <- trimws(x$raw_value)
  x$flag_missing <- is.na(raw) | raw %in% c("", "NA", "NaN", "N/A", "#VALUE!")
  x$value <- strict_numeric(raw)
  x$flag_parse <- !x$flag_missing & !is.finite(x$value)
  x$flag_unit <- is.na(x$unit) | x$unit != variables$unit[j]
  x$flag_domain <- is.finite(x$value) &
    (x$value < variables$lower[j] | x$value > variables$upper[j])
  keys <- c(if (station_grain) "station_key", "region", "layer", "year", "quarter", "variable")
  require_columns(x, keys)
  dup <- duplicated(x[keys]) | duplicated(x[keys], fromLast = TRUE)
  # All members of an ambiguous key are retained and quarantined. No arbitrary winner.
  x$flag_duplicate <- dup
  x$eligible <- !(x$flag_missing | x$flag_parse | x$flag_unit | x$flag_domain | dup)
  x$flag_outlier_review <- FALSE
  groups <- split(seq_len(nrow(x)), interaction(x$region, x$layer, x$variable, x$quarter, drop = TRUE))
  for (ids in groups) {
    ok <- ids[x$eligible[ids]]
    if (length(ok) < 8L) next
    qs <- stats::quantile(x$value[ok], c(.25, .75), names = FALSE, type = 7)
    spread <- diff(qs)
    if (spread > 0) x$flag_outlier_review[ok] <-
      x$value[ok] < qs[1] - iqr_multiplier * spread | x$value[ok] > qs[2] + iqr_multiplier * spread
  }
  flags <- grep("^flag_", names(x), value = TRUE)
  x$qc_flags <- apply(x[flags], 1L, function(z) {
    found <- sub("^flag_", "", flags[as.logical(z)])
    if (length(found)) paste(found, collapse = ";") else "pass"
  })
  x
}

complete_grid <- function(qc, config) {
  a <- config$analysis
  grid <- expand.grid(region = c("North", "Center", "South"), layer = "surface",
                      year = seq.int(a["start_year"], a["end_year"]), quarter = 1:4,
                      variable = config$variables$variable, stringsAsFactors = FALSE)
  grid$time_index <- 4L * (grid$year - a["start_year"]) + grid$quarter
  grid$unit <- config$variables$unit[match(grid$variable, config$variables$variable)]
  keys <- c("region", "layer", "year", "quarter", "variable")
  good <- qc[qc$eligible, c(keys, "value", "flag_outlier_review")]
  assert(!anyDuplicated(good[keys]), "Eligible keys remain duplicated.")
  out <- merge(grid, good, by = keys, all.x = TRUE, sort = FALSE)
  out <- out[order(out$variable, out$region, out$time_index), ]
  assert(nrow(out) == nrow(grid), "Quarterly join changed grid size.")
  out
}

summarise_qc <- function(qc) {
  groups <- split(seq_len(nrow(qc)), interaction(qc$region, qc$variable, drop = TRUE))
  do.call(rbind, lapply(groups, function(i) {
    z <- qc[i, ]
    cbind(z[1, c("region", "layer", "variable", "unit")],
          data.frame(n_records = nrow(z), n_eligible = sum(z$eligible),
          missing = sum(z$flag_missing), parse = sum(z$flag_parse),
          unit_mismatch = sum(z$flag_unit), domain = sum(z$flag_domain),
          duplicate = sum(z$flag_duplicate), review_outlier = sum(z$flag_outlier_review)))
  }))
}

aggregate_stations <- function(qc, stations) {
  require_columns(qc, c("station_key", "region", "layer", "year", "quarter", "variable", "eligible", "value"))
  assert(!anyDuplicated(stations$station_key), "Station mapping must be unique.")
  j <- match(qc$station_key, stations$station_key)
  assert(!anyNA(j) && all(qc$region == stations$region[j]), "Station mapping mismatch.")
  keys <- c("station_key", "region", "layer", "year", "quarter", "variable")
  assert(!anyDuplicated(qc[qc$eligible, keys]), "Ambiguous station-quarter measurements.")
  group <- interaction(qc$region, qc$layer, qc$year, qc$quarter, qc$variable, drop = TRUE)
  do.call(rbind, lapply(split(seq_len(nrow(qc)), group), function(i) {
    z <- qc[i, ]; good <- z$eligible & is.finite(z$value)
    data.frame(region = z$region[1], layer = z$layer[1], year = z$year[1], quarter = z$quarter[1],
               variable = z$variable[1], value = safe_mean_monitoring(z$value[good]),
               station_n = sum(good), expected_station_n = sum(stations$region == z$region[1]),
               aggregation = "equal_station_mean")
  }))
}
