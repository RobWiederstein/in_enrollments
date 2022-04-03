# compute change ----
districts <- readRDS("./in_school_district_map.rds")
enrollments <- readRDS("./in_enrollments.rds")

table <- 
        enrollments |> 
        dplyr::filter(year == 2022) |> 
        dplyr::filter(nces_id %in% districts$nces_id)
change <-
        enrollments |>
        dplyr::filter(year %in% c(2006, 2022)) |>
        tidyr::pivot_wider(
                names_from = year,
                values_from = tot_students
        ) |>
        dplyr::mutate(tot_chg_enrollment = (`2022` - `2006`) / `2006`) |>
        dplyr::mutate(tot_chg_enrollment = round(tot_chg_enrollment * 100, 2)) |>
        dplyr::select(nces_id, corp_id, corp_name, tot_chg_enrollment) |>
        dplyr::distinct(corp_id, .keep_all = T) |>
        tidyr::drop_na() |> 
        dplyr::select(nces_id, tot_chg_enrollment)

table <-dplyr::left_join(table, change, by = c("nces_id"))

saveRDS(table, "./in_enrollment_table.rds")
                         