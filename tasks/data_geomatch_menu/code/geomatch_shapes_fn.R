geomatch_shapes <- function(df, map, rows_per_chunk) {
  #split df into chunks of size rows_per_chunk to avoid memory issues
  df_split <- split(df, ceiling(seq_along(df$id)/rows_per_chunk))
  #create empty dataframe to store results
  df_matched <- data.frame()
  #loop through each chunk
  for (i in 1:length(df_split)) {
    #run st_intersection on each chunk
    df_split[[i]] <- df_split[[i]] %>%
        mutate(total_area = st_area(geometry))
    intersections <- st_intersection(df_split[[i]], map)
    #calcualte the area of each intersection
    intersections <- intersections %>%
        mutate(intersect_area = st_area(geometry))
    #bind the results to df_matched
    df_matched <- rbind(df_matched, intersections)
    suppressWarnings(
    df_matched <- df_matched %>% select(-geometry) %>% as.data.frame()
  )
  }
  return(df_matched)
}
# This is comparable to `geomatch_lines` in tasks/data_geomatch_menu/code/geomatch_lines_fn.R

create_sf_geometry <- function(df, lat_pattern, long_pattern, crs) {
  lat_cols <- grep(lat_pattern, names(df), value = TRUE)
  long_cols <- grep(long_pattern, names(df), value = TRUE)
  
  # Ensure that there are equal numbers of lat and long variables
  if(length(lat_cols) != length(long_cols)){
    stop("Unequal number of latitude and longitude columns.")
  }
  
  df %>%
    # create list-column with sf POINT objects
    mutate(
      geometry_list = pmap(list(df[lat_cols], df[long_cols]), 
                          ~ {
                            x = unlist(.x)
                            y = unlist(.y)
                            good_values = !is.na(x) & !is.na(y) & is.numeric(x) & is.numeric(y)
                            x = x[good_values]
                            y = y[good_values]
                            st_multipoint(cbind(x, y), dim = "XY")
                          }
                         )
    ) %>%
    # convert dataframe to sf object
    st_as_sf() -> df_sf
  
  # Set the CRS of the sf object
  st_crs(df_sf) <- crs
  
  return(df_sf)
}