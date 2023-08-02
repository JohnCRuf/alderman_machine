map_load <- function(mapfile) {
    map <- st_read(mapfile)

if (grepl("2003", mapfile)) {
  map <- map %>%
    rename(
      ward_locate = WARD,
      precinct_locate = PRECINCT,
      ward_precinct_locate = WARD_PRECI
    )
    #set crs to 4326
        map <- st_transform(map, 4326)
} else {
  map <- map %>%
    rename(
      ward_locate = ward, 
      precinct_locate = precinct, 
      ward_precinct_locate = full_text
    )
}
map <- st_transform(map, 4326)
return(map)
}