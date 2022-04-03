# plot map  ----
library(leaflet)
library(leafpop)
library(leaflet.providers)
districts <- readRDS("./in_school_district_map.rds")
# create factor variable ----
pal <- colorFactor(
    palette = "BrBG",
    domain = districts$tot_chg_factor,
    ordered = T
)
map <-
    leaflet() |>
    #addProviderTiles("CartoDB.Positron") |>
    addTiles() |> 
    fitBounds(-88.09, 37.77, -84.78, 41.76) |>
    addPolygons(
        data = districts,
        color = ~ pal(tot_chg_factor),
        weight = 2,
        fillOpacity = .3,
        popup = popupImage(
            img = districts$images,
            src = "local",
            embed = TRUE,
            height = 300,
            width = 600
        )
    ) |>
    addLegend(
        position = "bottomright",
        pal = pal,
        title = "% Student Change:",
        values = districts$tot_chg_factor
     )
map
saveRDS(map, "./in_enrollment_change_map.rds")
