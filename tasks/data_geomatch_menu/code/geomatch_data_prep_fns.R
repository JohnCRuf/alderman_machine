unique_pairs_filter <- function(df, num, GEQ = FALSE) {
  # Helper function to determine if a lat-lon pair is valid
  is_valid_pair <- function(lat, lon) {
    is.numeric(lat) && !is.na(lat) && is.numeric(lon) && !is.na(lon)
  }
  
  df <- df %>%
    rowwise() %>%
    mutate(
      unique_numeric_pairs = {
        # Extract all columns starting with "lat_" and "lon_"
        lats <- c_across(starts_with("lat_"))
        lons <- c_across(starts_with("lon_"))
        
        # Create pairs
        pairs <- mapply(function(lat, lon) {
          if (is_valid_pair(lat, lon)) {
            paste0(lat, "_", lon)
          } else {
            NA_character_
          }
        }, lats, lons)
        
        # Return count of unique valid pairs
        length(unique(na.omit(pairs)))
      }
    )
  
  # Filter based on user input
  if (GEQ) {
    df <- df %>% filter(unique_numeric_pairs >= num)
  } else {
    df <- df %>% filter(unique_numeric_pairs == num)
  }

  #remove unique numeric pairs column
    df <- df %>%
        select(-unique_numeric_pairs)
  
  return(df)
}

convert_lat_lon_to_na <- function(df) {
  df <- df %>%
    rowwise() %>%
    mutate(across(starts_with(c("lat_", "lon_")), ~ifelse(is.numeric(.), ., NA_real_))) %>%
    ungroup()
  return(df)
}

extract_unique_lat_lon <- function(df_points) {
  
  df_points <- df_points %>%
    rowwise() %>%
    mutate(
      lat = ifelse(is.na(lat_1) | !is.numeric(lat_1), lat_2, lat_1),
      long = ifelse(is.na(lon_1) | !is.numeric(lon_1), lon_2, lon_1)
    ) %>%
    ungroup()
  
  return(df_points)
}