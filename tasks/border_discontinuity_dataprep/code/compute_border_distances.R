compute_area_to_ward_distances <- function(small_map, wards_map) {

    crs_small_map <- st_crs(small_map)
    crs_wards_map <- st_crs(wards_map)

    if (crs_small_map != crs_wards_map) {
    wards_map <- st_transform(wards_map, crs_small_map)
    }

    # Find the nearest ward for each precinct and calculate distance
    # Initialize a dataframe to store the results
    small_unit_data <- data.frame(nearest_ward = character(nrow(small_map)), 
                                distance_to_ward = numeric(nrow(small_map)), 
                                border_precinct = numeric(nrow(small_map)),
                                stringsAsFactors = FALSE)

    # Iterate over each precinct shape
    for (i in seq_len(nrow(small_map))) {
    # save the geometry of the current precinct
    #print i
    print(i)
    geom <- small_map$geometry[i]

    # Exclude the current ward from the search
    current_ward <- small_map$ward[i]
    other_wards <- wards_map[wards_map$ward_locate != current_ward, ]

    # Calculate nearest ward and distance
    distances <- st_distance(other_wards, geom)
    nearest_ward_idx <- which.min(distances)[1]
    nearest_ward <- other_wards$ward_locate[nearest_ward_idx]
    distance_to_ward <- as.numeric(distances[nearest_ward_idx])

    # Store results
    small_unit_data$nearest_ward[i] <- nearest_ward
    small_unit_data$distance_to_ward[i] <- distance_to_ward
    }

    # Bind the small_map data
    final_df <- cbind(small_map, small_unit_data)

    return(dataframe = final_df)
}