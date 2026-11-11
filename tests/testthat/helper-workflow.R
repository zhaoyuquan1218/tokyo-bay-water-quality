root <- normalizePath(file.path("..", ".."), winslash = "/", mustWork = TRUE)
source(file.path(root, "R/utils.R"))
source(file.path(root, "R/acquire.R"))
source(file.path(root, "R/qc.R"))
source(file.path(root, "R/statistics.R"))
vars <- data.frame(variable = "DOC", unit = "mg C/L", lower = 0, upper = Inf)
fixture <- function(values = c("1", "2", "3", "4")) {
  data.frame(record_id = paste0("synthetic-test-", seq_along(values)), region = "North",
    layer = "surface", year = 1981L + (seq_along(values) - 1L) %/% 4L,
    quarter = (seq_along(values) - 1L) %% 4L + 1L, variable = "DOC", unit = "mg C/L", raw_value = values)
}
