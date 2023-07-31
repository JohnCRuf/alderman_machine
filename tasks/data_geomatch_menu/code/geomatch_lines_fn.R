create_sf_lines <- function(df, lat1, lon1, lat2, lon2, crs) {
  # Create an sf object from your dataframe
  sf_object <- df %>% 
    rowwise() %>%
    mutate(geometry = list(st_linestring(matrix(c(!!sym(lon1), !!sym(lat1), !!sym(lon2), !!sym(lat2)), nrow = 2, byrow = TRUE)))) %>%
    st_as_sf(crs = crs)

  # Return the sf object
  return(sf_object)
}

geomatch_lines <- function(lines, map,rows_per_chunk) {
  #split lines into chunks of size rows_per_chunk to avoid memory issues
  lines_split <- split(lines, ceiling(seq_along(lines$id)/rows_per_chunk))
  #create empty dataframe to store results
  df_line_matched <- data.frame()
  #loop through each chunk
  for (i in 1:length(lines_split)) {
    #calculate the total length of each line before merge
    lines_split[[i]] <- lines_split[[i]] %>%
      mutate(total_length = st_length(geometry))
    #run st_intersection on each chunk
    intersections <- st_intersection(lines_split[[i]], map)
    #calculate the length of each intersection and of each original line
    intersections <- intersections %>%
      mutate(intersect_length = st_length(geometry))
    intersections <- intersections %>% select(-geometry) %>% as.data.frame()
    #bind the results to df_line_matched
    df_line_matched <- rbind(df_line_matched, intersections)
  }
  #suppress warnings
  

  return(df_line_matched)
}