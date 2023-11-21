compute_precinct_distances <- function(precincts) {

    # Aggregate precincts into wards
    wards_map <- precincts %>%
    group_by(ward_locate) %>%
    summarise(geometry = st_union(geometry))

    # Create a dataframe of centroids of each precinct
    centroids <- st_centroid(precincts)
    #confirm that crs is the same for both
    crs_precincts <- st_crs(precincts)
    crs_wards_map <- st_crs(wards_map)

    if (crs_precincts != crs_wards_map) {
    wards_map <- st_transform(wards_map, crs_precincts)
    }

    # Find the nearest ward for each centroid and calculate distance
    # Initialize a dataframe to store the results
    centroids_data <- data.frame(Nearest_Ward = character(nrow(centroids)), 
                                Distance_to_Ward = numeric(nrow(centroids)), 
                                stringsAsFactors = FALSE)

    # Iterate over each centroid
    for (i in 1:nrow(centroids)) {
    coord <- st_coordinates(centroids[i, ])
    point <- st_sfc(st_point(coord), crs = st_crs(centroids))

    # Exclude the current ward from the search
    current_ward <- centroids$ward_locate[i]
    other_wards <- wards_map[wards_map$ward_locate != current_ward, ]

    # Calculate nearest ward and distance
    distances <- st_distance(other_wards, point)
    nearest_ward_idx <- which.min(distances)
    nearest_ward <- other_wards$ward_locate[nearest_ward_idx]
    distance_to_ward <- as.numeric(distances[nearest_ward_idx])

    # Store results
    centroids_data$Nearest_Ward[i] <- nearest_ward
    centroids_data$Distance_to_Ward[i] <- distance_to_ward
    }

    # Bind the precincts and centroids dataframes
    centroids_df <- cbind(precincts, centroids_data)

    return(dataframe = centroids_df)
}