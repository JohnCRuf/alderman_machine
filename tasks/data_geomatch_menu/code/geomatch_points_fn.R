geomatch_single_coordinate <- function(df, map, CRS) {
    coordinates <- st_as_sf(df, coords = c("long", "lat"), crs = CRS)
    assigned <- st_join(coordinates, map, join = st_within)
    return(assigned)
}