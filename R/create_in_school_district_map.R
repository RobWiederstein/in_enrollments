# compute change ----
enrollments <- readRDS("./in_enrollments.rds")
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
        tidyr::drop_na()


# merge with gis file ----
unsd <- sf::st_read(
        dsn = "cb_2020_18_unsd_500k",
        layer = "cb_2020_18_unsd_500k"
) |>
        sf::st_transform("+proj=longlat +datum=WGS84") |>
        sf::st_simplify() |> 
        dplyr::rename_with(.fn = ~ janitor::make_clean_names(.x)) |>
        dplyr::select(geoid, geometry) |>
        dplyr::rename(nces_id = geoid)
# join unsd with enrollments
unsd <- dplyr::left_join(unsd, change, by = "nces_id")
# join unsd with image files ----
# build dataframe of images paths and nces id ----
images <- list.files(
        path = "./img",
        full.names = T
)
nces_id <- unlist(lapply(strsplit(images, split = "_"), "[", 2))
images <- data.frame(images = images, nces_id = nces_id)
# join image paths to districts ----
districts <- dplyr::left_join(unsd, images, by = "nces_id")
#factor variable for change ----
districts$tot_chg_factor <-
        ggplot2::cut_number(
                x = districts$tot_chg_enrollment,
                n = 7
        )
# save map
saveRDS(districts, "./in_school_district_map.rds")
