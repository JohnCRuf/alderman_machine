geomatch_shapes <- function(df, map, rows_per_chunk) {
  #split df into chunks of size rows_per_chunk to avoid memory issues
  df_split <- split(df, ceiling(seq_along(df$id)/rows_per_chunk))
  #create empty dataframe to store results
  df_matched <- data.frame()
  #loop through each chunk
  for (i in 1:length(df_split)) {
    #make sure geometry_list is valid
    df_split[[i]] <- df_split[[i]] %>%
      mutate(geometry_list = st_make_valid(geometry_list))
    #run st_intersection on each chunk
    df_split[[i]] <- df_split[[i]] %>%
        mutate(total_area = st_area(geometry_list))
    intersections <- st_intersection(df_split[[i]], map)
    #calcualte the area of each intersection
    intersections <- intersections %>%
        mutate(intersect_area = st_area(geometry_list))
    #bind the results to df_matched
    df_matched <- rbind(df_matched, intersections)
  print(i)
  }
    suppressWarnings(
    df_matched <- df_matched %>% select(-geometry_list) %>% as.data.frame()
  )
  return(df_matched)
}
# This is comparable to `geomatch_lines` in tasks/data_geomatch_menu/code/geomatch_lines_fn.R
create_sf_geometry <- function(df, lat_pattern, lon_pattern, crs) {
  lat_cols <- grep(lat_pattern, names(df), value = TRUE)
  lon_cols <- grep(lon_pattern, names(df), value = TRUE)
  
  # Ensure that there are equal numbers of lat and lon variables
  if(length(lat_cols) != length(lon_cols)){
    stop("Unequal number of latitude and longitude columns.")
  }

  df %>%
    rowwise() %>%
    mutate(
      lat_values = list(c(across(all_of(lat_cols)))),
      lon_values = list(c(across(all_of(lon_cols))))
    ) %>%
    mutate(
      geometry_list = {
        y = unlist(lat_values)  # latitudes are 'y'
        x = unlist(lon_values)  # longitudes are 'x'
        good_values = !is.na(x) & !is.na(y) & sapply(x, is.numeric) & sapply(y, is.numeric)
        x = x[good_values]
        y = y[good_values]
        
        # Find centroid of the points
        centroid_x = mean(x)
        centroid_y = mean(y)
        
        # Sort points based on angle with respect to the centroid
        angles = atan2(y - centroid_y, x - centroid_x)
        order = order(angles)
        
        x = x[order]
        y = y[order]
        
        # Remove duplicate vertices (if any)
        unique_vertices <- which(!duplicated(cbind(x, y)))
        x = x[unique_vertices]
        y = y[unique_vertices]

        # Close the polygon by appending the first point to the end
        x = c(x, x[1])
        y = c(y, y[1])
        
        # Create the polygon
        list(st_polygon(list(cbind(x, y)), dim = "XY"))
      }
    ) %>%
    # Drop temporary columns
    select(-lat_values, -lon_values) %>%
    # convert dataframe to sf object
    st_as_sf() -> df_sf

  # Set the CRS of the sf object
  st_crs(df_sf) <- crs
  return(df_sf)
}


is_na_or_non_numeric <- function(x) {
  is.na(x) | !is.numeric(x)
}