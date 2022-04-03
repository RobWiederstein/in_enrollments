library(ggplot2)
library(ggthemes)
library(dplyr)
# fetch school districts ----
districts <- readRDS("./in_school_district_map.rds")
# fetch student enrollment ----
students <- readRDS("./in_enrollments.rds") |>
        dplyr::filter(nces_id %in% districts$nces_id)
# plot enrollment - one plot for each school district ----
district_names <-
        students |>
        dplyr::arrange(nces_id) |>
        dplyr::select(corp_name) |>
        dplyr::pull(corp_name) |>
        unique()
# begin for loop ----
for (i in 1:length(district_names)) {
        mydf <- dplyr::filter(students, corp_name == district_names[[i]])
        p <-
                mydf |>
                ggplot() +
                aes(
                        x = year,
                        y = tot_students,
                        group = corp_name
                ) +
                labs(
                        title = district_names[[i]],
                        subtitle = "Total Student Enrollments"
                ) +
                geom_line(color = "#018571") +
                theme_fivethirtyeight(base_size = 4)
        filename <- paste0(
                "./img/plot_",
                unique(mydf$nces_id),
                "_",
                stringr::str_pad(i, width = 3, side = "left", pad = "0"),
                ".png"
        )
        ggsave(
                p,
                filename = filename,
                height = 1,
                width = 2,
                units = "in"
        )
}
