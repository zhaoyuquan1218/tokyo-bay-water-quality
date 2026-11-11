# Exercise a fresh download in an isolated ignored scratch directory.
source("renv/activate.R")
source("R/utils.R"); source("R/acquire.R")
config <- read_config()
scratch <- tempfile(pattern = "acquisition-", tmpdir = file.path(getwd(), "outputs", "validation"))
dir.create(scratch, recursive = TRUE, showWarnings = FALSE)
old <- setwd(scratch)
tryCatch({
  path <- acquire_source(config)
  stopifnot(identical(unname(tools::md5sum(path)), config$source$checksum))
  message("Fresh R download and pinned checksum verified.")
}, finally = setwd(old))
