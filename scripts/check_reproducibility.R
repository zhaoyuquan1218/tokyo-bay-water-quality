source("renv/activate.R")
paths <- c("data/processed/regional_quarterly.csv", "outputs/report.md",
           list.files("outputs/tables", full.names = TRUE), list.files("outputs/figures", full.names = TRUE))
before <- tools::md5sum(paths)
exe <- if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"
status <- system2(file.path(R.home("bin"), exe), c("--vanilla", "run_all.R", "--offline"))
if (status != 0L) stop("Reproduction run failed.")
after <- tools::md5sum(paths)
if (!identical(before, after)) stop("Generated products changed: ", paste(names(before)[before != after], collapse = ", "))
message("Identical hashes for all ", length(paths), " data, table, report and PNG products.")
