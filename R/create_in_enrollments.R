library(dplyr)
# download ----
url <- "https://www.in.gov/doe/files/school-enrollment-grade-2006-22.xlsx"
destfile <- paste0("./data/", basename(url))
if(!file.exists(destfile)){
    download.file(url = url, destfile = destfile)
}
sheets <- readxl::excel_sheets(destfile)
# read ----
read_excel_allsheets <- function(filename) {
    sheets <- readxl::excel_sheets(filename)
    x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
    names(x) <- sheets
    x
}
l <- read_excel_allsheets(destfile)
# rename columns ----
col_names <- c(
    "corp_id",
    "corp_name",
    "schl_id",
    "schl_name",
    "pre_k",
    "kindergarten",
    paste0("grade_", 1:12),
    "grade_12_plus_adult",
    "total_enrollment"
)

for (i in seq_along(l)) {
    colnames(l[[i]]) <- col_names
    l[[i]]$year <- names(l)[i]
}
# combine ----
enrollments <-
    data.frame(Reduce(rbind, l)) |>
    dplyr::select(year, everything()) |>
    dplyr::select(-total_enrollment) |>
    tidyr::pivot_longer(
        pre_k:grade_12_plus_adult,
        names_to = "grade",
        values_to = "students"
    ) |>
    dplyr::mutate(across(corp_name, ~ gsub("Sch ", "School ", .x))) |>
    dplyr::group_by(year, corp_id) |>
    dplyr::summarize(
        tot_students = sum(students, na.rm = T)
    ) |>
    dplyr::mutate(year = as.integer(year)) |>
    arrange(year, corp_id)
# add nces_id ----
file <- "https://www.in.gov/doe/files/2021-2022-school-directory-2022-02-02.xlsx"
idoe_crosswalk <-
    rio::import(file = file) |>
    rename_with(.fn = ~ janitor::make_clean_names(.x)) |>
    dplyr::select(nces_id, idoe_corporation_id, corporation_name) |>
    dplyr::rename(
        corp_id = idoe_corporation_id,
        corp_name = corporation_name
    )
enrollments <-
    dplyr::left_join(enrollments, idoe_crosswalk, by = "corp_id")
enrollments <-
    enrollments |>
    dplyr::select(year, nces_id, corp_id, corp_name, tot_students)
saveRDS(enrollments, "./in_enrollments.rds")