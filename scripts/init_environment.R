# Maintainer-only: capture the packages actually used and installed on the build host.
# Ordinary users should run scripts/setup.R, which restores rather than updates the environment.
dir.create("renv/bootstrap-library", recursive = TRUE, showWarnings = FALSE)
bootstrap <- normalizePath("renv/bootstrap-library", winslash = "/")
if (!requireNamespace("renv", quietly = TRUE))
  install.packages("renv", lib = bootstrap, repos = "https://cloud.r-project.org")
.libPaths(c(bootstrap, .libPaths()))
renv::init(bare = TRUE, restart = FALSE)
renv::hydrate(packages = c("readxl", "ggplot2", "testthat", "jsonlite"), prompt = FALSE)
renv::snapshot(packages = c("renv", "readxl", "ggplot2", "testthat", "jsonlite"), prompt = FALSE)
