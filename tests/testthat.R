if (!file.exists("config/source.csv")) stop("Run tests from the project root.")
if (file.exists("renv/activate.R")) source("renv/activate.R")
if (!requireNamespace("testthat", quietly = TRUE)) stop("Install locked dependencies with scripts/setup.R.")
testthat::test_dir("tests/testthat", reporter = "summary", stop_on_failure = TRUE)
