compute_precinct_distances <- function(precincts) {

    # Aggregate precincts into wards
    wards_map <- precincts %>%
    group_by(ward_locate) %>%
    summarise(geometry = st_union(geometry))
    crs_precincts <- st_crs(precincts)
    crs_wards_map <- st_crs(wards_map)

    if (crs_precincts != crs_wards_map) {
    wards_map <- st_transform(wards_map, crs_precincts)
    }

    # Find the nearest ward for each precinct and calculate distance
    # Initialize a dataframe to store the results
    precinct_data <- data.frame(nearest_ward = character(nrow(precincts)), 
                                distance_to_ward = numeric(nrow(precincts)), 
                                border_precinct = numeric(nrow(precincts)),
                                stringsAsFactors = FALSE)

    # Iterate over each precinct shape
    for (i in seq_len(nrow(precincts))) {
    # save the geometry of the current precinct
    geom <- precincts$geometry[i]

    # Exclude the current ward from the search
    current_ward <- precincts$ward_locate[i]
    other_wards <- wards_map[wards_map$ward_locate != current_ward, ]

    # Calculate nearest ward and distance
    distances <- st_distance(other_wards, geom)
    nearest_ward_idx <- which.min(distances)
    nearest_ward <- other_wards$ward_locate[nearest_ward_idx]
    distance_to_ward <- as.numeric(distances[nearest_ward_idx])
    #create a dummy variable if the precinct is a border precinct
    if (distance_to_ward == 0) {
        border_precinct <- 1
    } else {
        border_precinct <- 0
    }

    # Store results
    precinct_data$nearest_ward[i] <- nearest_ward
    precinct_data$distance_to_ward[i] <- distance_to_ward
    precinct_data$border_precinct[i] <- border_precinct
    }

    # Bind the precincts data
    precinct_df <- cbind(precincts, precinct_data)

    return(dataframe = precinct_df)
}