testthat::test_that("qualifiers and non-finite values are not silently converted to observations", {
  z <- qc_records(fixture(c("", "<0.1", "Inf", "-1", "1e-2", "NaN", "abc", "1,000")), vars)
  testthat::expect_equal(sum(z$eligible), 1L)
  testthat::expect_equal(z$value[5], .01)
  testthat::expect_true(all(z$flag_parse[c(2, 3, 7, 8)]))
  testthat::expect_true(z$flag_domain[4])
  testthat::expect_true(all(z$flag_missing[c(1, 6)]))
  testthat::expect_equal(nrow(z), 8L)
})

testthat::test_that("duplicate groups and unit conflicts are quarantined with provenance retained", {
  x <- fixture(); x$quarter[2] <- 1L; x$unit[3] <- "umol/L"
  z <- qc_records(x, vars)
  testthat::expect_true(all(z$flag_duplicate[1:2]))
  testthat::expect_false(any(z$eligible[1:3]))
  testthat::expect_equal(z$raw_value, x$raw_value)
  testthat::expect_equal(z$record_id, x$record_id)
})

testthat::test_that("missing quarters remain explicit and incomplete years are not averaged", {
  x <- fixture(); x$raw_value[2] <- ""
  z <- qc_records(x, vars)
  cfg <- list(analysis = c(start_year = 1981, end_year = 1981), variables = vars)
  grid <- complete_grid(z, cfg)
  testthat::expect_equal(nrow(grid), 12L)
  testthat::expect_true(is.na(grid$value[grid$region == "North" & grid$quarter == 2]))
  a <- annual_summary(grid)
  testthat::expect_true(all(is.na(a$annual_mean)))
  testthat::expect_equal(a$n_quarters[a$region == "North"], 3L)
  testthat::expect_true(is.na(safe_mean_monitoring(c(NA_real_, NA_real_))))
})

testthat::test_that("extreme observations are flagged for review but retained", {
  x <- fixture(as.character(rep(1:10, each = 4))); x$raw_value[37] <- "9999"
  z <- qc_records(x, vars)
  testthat::expect_true(z$flag_outlier_review[37])
  testthat::expect_true(z$eligible[37])
})

testthat::test_that("station mapping and layers remain distinct and station means are equally weighted", {
  stations <- data.frame(station_key = c("A", "B"), region = "North")
  x <- fixture(c("2", "6", "10", "14")); x$quarter <- 1L
  x$station_key <- rep(c("A", "B"), 2); x$layer <- rep(c("surface", "bottom"), each = 2)
  z <- qc_records(x, vars, station_grain = TRUE)
  out <- aggregate_stations(z, stations)
  testthat::expect_equal(out$value[out$layer == "surface"], 4)
  testthat::expect_equal(out$value[out$layer == "bottom"], 12)
  testthat::expect_true(all(out$station_n == 2))
  z$region[1] <- "South"
  testthat::expect_error(aggregate_stations(z, stations), "mapping")
})

testthat::test_that("malformed categorical and time keys fail explicitly", {
  x <- fixture(); x$quarter[1] <- 1.5
  testthat::expect_error(qc_records(x, vars), "quarter")
  x <- fixture(); x$region[1] <- "Central"
  testthat::expect_error(qc_records(x, vars), "regional")
  x <- fixture(); x$record_id[1] <- ""
  testthat::expect_error(qc_records(x, vars), "record ID")
})
