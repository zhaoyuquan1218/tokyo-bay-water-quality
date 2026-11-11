# Restore the lockfile into a separate initially empty project-local library.
source("renv/activate.R")
check <- file.path(getwd(), "renv", "restore-check")
dir.create(check, recursive = TRUE, showWarnings = FALSE)
Sys.setenv(RENV_CONFIG_CACHE_ENABLED = "FALSE")
renv::restore(library = check, prompt = FALSE)
lock <- renv::lockfile_read("renv.lock")
.libPaths(c(check, .Library))
for (p in names(lock$Packages)) {
  installed <- utils::packageDescription(p, lib.loc = check)
  if (is.na(installed[1]) || installed$Version != lock$Packages[[p]]$Version)
    stop("Restored package does not match lockfile: ", p)
}
Sys.unsetenv("RENV_PATHS_LIBRARY")
Sys.setenv(R_LIBS_USER = normalizePath(check, winslash = "/"),
           R_LIBS = normalizePath(check, winslash = "/"),
           RENV_CONFIG_AUTOLOADER_ENABLED = "FALSE")
for (script in c("scripts/assert_locked_library.R", "run_all.R", "tests/testthat.R", "scripts/validate_outputs.R")) {
  exe <- if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"
  status <- system2(file.path(R.home("bin"), exe),
                    c("--vanilla", script, if (script == "run_all.R") "--offline"))
  if (status != 0L) stop("Clean-library validation failed: ", script)
}
message("Clean-library restore and execution verified for ", length(lock$Packages), " locked packages.")
