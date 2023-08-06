menu_geocode <- function(df, var_name, batch_size) {
    df <- df %>%
        mutate(singlelineaddress = paste0(str_replace_all(!!sym(var_name), ",", " "), ", Chicago, IL"),
        singlelineaddress = ifelse(is.na(!!sym(var_name)), NA, singlelineaddress))
    #if var_name is NA, then singlelineaddress will be NA
    #sort by singlelineaddress to maximize number of identical addresses per batch
    df <- df[order(df$singlelineaddress),]
        # Split the data frame into chunks
    chunks <- split(df, ceiling(seq_along(df[[var_name]])/batch_size))
    # Apply geocode_combine to each chunk and combine results
    results <- map_dfr(chunks, function(chunk) {
        geocode_combine(chunk,
        queries = list(
            list(method = 'census'),
            list(method = 'google')
        ),
        global_params = list(address = 'singlelineaddress'),
        cascade = TRUE,
        return_list = FALSE
        )
    }) %>%
        select(-singlelineaddress)
    # Geocode "Chicago, IL"
    chicago_df <- data.frame(address = 'Chicago, IL')
    chicago_coords <- geocode(chicago_df, method = 'google', address = 'address')
    # Replace with NA when the coordinates match that of "Chicago, IL"
    results <- results %>%
      mutate(lat = ifelse(lat == chicago_coords$lat & long == chicago_coords$long, NA, lat),
             long = ifelse(long == chicago_coords$long & lat == chicago_coords$lat, NA, long))

    return (results)
}
menu_geocode_googleonly <- function(df, var_name, batch_size) {
    df <- df %>%
        mutate(singlelineaddress = paste0(str_replace_all(!!sym(var_name), ",", " "), ", Chicago, IL"),
        singlelineaddress = ifelse(is.na(!!sym(var_name)), NA, singlelineaddress))
    #if var_name is NA, then singlelineaddress will be NA
    #sort by singlelineaddress to maximize number of identical addresses per batch
    df <- df[order(df$singlelineaddress),]
        # Split the data frame into chunks
    chunks <- split(df, ceiling(seq_along(df[[var_name]])/batch_size))
    # Apply geocode_combine to each chunk and combine results
    results <- map_dfr(chunks, function(chunk) {
        geocode_combine(chunk,
        queries = list(
            list(method = 'google')
        ),
        global_params = list(address = 'singlelineaddress'),
        cascade = TRUE,
        return_list = FALSE
        )
    }) %>%
        select(-singlelineaddress)
    # Geocode "Chicago, IL"
    chicago_df <- data.frame(address = 'Chicago, IL')
    chicago_coords <- geocode(chicago_df, method = 'google', address = 'address')
    # Replace with NA when the coordinates match that of "Chicago, IL"
    results <- results %>%
      mutate(lat = ifelse(lat == chicago_coords$lat & long == chicago_coords$long, NA, lat),
             long = ifelse(long == chicago_coords$long & lat == chicago_coords$lat, NA, long))

    return (results)
}
#comments to test code
# library(tidyverse)
# library(tidygeocoder)
# main_df <- read_csv("../temp/normal_address_df.csv")
# test_df <- main_df[1:1000,]
# geo_results <- menu_geocode(test_df, "address", 500)

#error correcting function that removes all coordinates obviously not in Chicago

filter_chicago_coordinates <- function(df) {
  # Define the bounding box around Chicago
  lat_min <- 41.6445   # Approximate southernmost latitude
  lat_max <- 42.0231   # Approximate northernmost latitude
  lon_min <- -87.9401  # Approximate westernmost longitude
  lon_max <- -87.5240  # Approximate easternmost longitude
  
  lat_cols <- grep("^lat_", names(df))
  lon_cols <- grep("^lon_", names(df))
  
  # Loop through each lat and lon column to apply the conditions
  for(i in 1:length(lat_cols)) {
    df <- df %>%
      mutate(
        !!names(df)[lat_cols[i]] := ifelse(
          (get(names(df)[lat_cols[i]]) < lat_min | get(names(df)[lat_cols[i]]) > lat_max) | 
          (get(names(df)[lon_cols[i]]) < lon_min | get(names(df)[lon_cols[i]]) > lon_max), 
          NA, 
          get(names(df)[lat_cols[i]])
        ),
        !!names(df)[lon_cols[i]] := ifelse(
          is.na(get(names(df)[lat_cols[i]])), 
          NA, 
          get(names(df)[lon_cols[i]])
        )
      )
  }
  return(df)
}