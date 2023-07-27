create_sf_lines <- function(df, lat1, lon1, lat2, lon2, crs) {
  # Create an sf object from your dataframe
  sf_object <- df %>% 
    rowwise() %>%
    mutate(geometry = list(st_linestring(matrix(c(!!sym(lon1), !!sym(lat1), !!sym(lon2), !!sym(lat2)), nrow = 2, byrow = TRUE)))) %>%
    st_as_sf(crs = crs)

  # Return the sf object
  return(sf_object)
}

geomatch_lines <- function(lines, map) {
  # Intersect the lines with the map
  intersections <- st_intersection(lines, map)

  # Calculate the length of each intersection and of each original line
  intersections <- intersections %>%
    mutate(intersect_length = st_length(geometry)) 

  return(intersections)
}