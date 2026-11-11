testthat::test_that("changed or corrupt inputs fail the checksum gate", {
  p <- tempfile(); on.exit(unlink(p)); writeLines("changed", p)
  testthat::expect_error(verify_checksum(p, "ef0874d94621c2fdb947bb3482a1d9d8"), "checksum")
})

testthat::test_that("approved six-station mapping is preserved", {
  s <- utils::read.csv(file.path(root, "config/stations.csv"), colClasses = "character")
  testthat::expect_equal(s$station_key, c("1210014", "1210015", "1210030", "1210035", "1310026", "1210038"))
  testthat::expect_equal(s$region, c("North", "North", "Center", "Center", "Center", "South"))
})

testthat::test_that("public workbook obeys the pinned schema and preserves analysis quarters", {
  path <- file.path(root, "data-raw/Tokyo_Bay_DOC_core_dataset_1981_2021.xlsx")
  testthat::skip_if_not(file.exists(path), "Run run_all.R to acquire public input for the integration test.")
  old <- setwd(root); on.exit(setwd(old))
  cfg <- read_config()
  verify_checksum(path, cfg$source$checksum)
  x <- read_published(path, cfg)
  testthat::expect_equal(nrow(x), 4920L)
  testthat::expect_setequal(x$region, c("North", "Center", "South"))
  testthat::expect_true(all(x$layer == "surface"))
  testthat::expect_true(any(x$quarter == 4 & as.integer(format(x$sample_date, "%Y")) > x$year))
  testthat::expect_equal(range(x$time_index), c(1, 164))
  z <- qc_records(x, cfg$variables)
  testthat::expect_equal(sum(z$flag_duplicate), 40L)
  testthat::expect_equal(sum(z$eligible), 4880L)
  cfg$variables$source_header[1] <- "DOC (undocumented unit)"
  testthat::expect_error(read_published(path, cfg), "schema or units")
})
