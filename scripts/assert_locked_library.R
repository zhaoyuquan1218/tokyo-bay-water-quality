# Used by the clean-library check to prohibit accidental fallback to global packages.
check <- normalizePath(file.path(getwd(), "renv", "restore-check"), winslash = "/")
lock <- jsonlite::read_json("renv.lock")
for (p in names(lock$Packages)) {
  found <- normalizePath(find.package(p), winslash = "/")
  if (!startsWith(tolower(found), paste0(tolower(check), "/"))) stop("Global-library fallback: ", p)
  if (utils::packageDescription(p)$Version != lock$Packages[[p]]$Version) stop("Version mismatch: ", p)
}
message("All ", length(lock$Packages), " packages resolve to the separate restored library.")
