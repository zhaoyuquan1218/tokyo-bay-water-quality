p <- "data-raw/Tokyo_Bay_DOC_core_dataset_1981_2021.xlsx"
for (s in c("README", "Variable_Dictionary")) {
  cat("\n", s, "\n")
  d <- suppressMessages(readxl::read_excel(p, sheet = s, col_names = FALSE))
  for (i in seq_len(nrow(d))) cat(paste(d[i, ], collapse = " | "), "\n")
}
d <- readxl::read_excel(p, sheet = "Combined_Data")
print(colSums(is.na(d)))
print(table(d[[1]]))
