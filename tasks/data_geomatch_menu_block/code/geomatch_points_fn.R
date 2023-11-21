geomatch_single_coordinate <- function(data, map, CRS) {
    coordinates <- st_as_sf(data, coords = c("long", "lat"), crs = CRS)
    assigned <- st_join(coordinates, map, join = st_within)
    return(assigned)
}