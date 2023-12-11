select_random_rows <- function(dataframe, num_rows = 50) {
  if (nrow(dataframe) < num_rows) {
    stop("The dataset contains fewer blocks than the number requested.")
  }
  
  selected_blocks <- dataframe[sample(nrow(dataframe), num_rows), ]
  return(selected_blocks)
}

find_adjacent_blocks <- function(spatial_data, selected_blocks, buffer_size = 0.001) {
  #sort spatial_data and selected_blocks by geoid10
    spatial_data <- spatial_data[order(spatial_data$geoid10),]
    selected_blocks <- selected_blocks[order(selected_blocks$geoid10),]
  # Slightly expand the selected blocks
  expanded_blocks <- st_buffer(st_geometry(selected_blocks), buffer_size)
  # Find intersecting indices with the expanded geometries
  intersecting_indices <- st_intersects(expanded_blocks, st_geometry(spatial_data))
  # Convert the list of indices to a numeric vector
  intersecting_indices <- unlist(intersecting_indices)
  # Subset spatial_data to get the intersecting blocks
  intersecting_blocks_df <- spatial_data[intersecting_indices, , drop = FALSE]
  # Remove the selected blocks from the intersecting set
  intersecting_blocks_df <- intersecting_blocks_df[!intersecting_blocks_df$geoid10 %in% selected_blocks$geoid10,]
  # Remove repeated blocks
  intersecting_blocks_df <- intersecting_blocks_df[!duplicated(intersecting_blocks_df$geoid10),]
  return(intersecting_blocks_df)
}

find_adjacent_blocks_union <- function(spatial_data, polygon, buffer_size = 0.001) {
  #sort spatial_data and selected_blocks by geoid10
    spatial_data <- spatial_data[order(spatial_data$geoid10),]
  #expand the polygon
    expanded_polygon <- st_buffer(st_geometry(polygon), buffer_size)
    # Find which blocks intersect with the polygon
    intersecting_indices <- st_intersects(st_geometry(expanded_polygon), st_geometry(spatial_data))
    # Convert the list of indices to a numeric vector
    intersecting_indices <- unlist(intersecting_indices)
    # Subset spatial_data to get the intersecting blocks
    intersecting_blocks_df <- spatial_data[intersecting_indices, , drop = FALSE]
    #remove repeated blocks
    intersecting_blocks_df <- intersecting_blocks_df[!duplicated(intersecting_blocks_df$geoid10),]
    #correct the geometry
    intersecting_blocks_df <- st_make_valid(intersecting_blocks_df)

  return(intersecting_blocks_df)
}

find_k_nearest_blocks_union <-function(spatial_data, polygon, k) {
    #sort spatial_data and selected_blocks by geoid10
    spatial_data <- spatial_data[order(spatial_data$geoid10),]
    # Find which blocks intersect with the polygon
    intersecting_indices <- st_nearest_feature(spatial_data, polygon, k = k)
    # Convert the list of indices to a numeric vector
    intersecting_indices <- unlist(intersecting_indices)
    # Subset spatial_data to get the intersecting blocks
    intersecting_blocks_df <- spatial_data[intersecting_indices, , drop = FALSE]
    #remove repeated blocks
    intersecting_blocks_df <- intersecting_blocks_df[!duplicated(intersecting_blocks_df$geoid10),]
    #correct the geometry
    intersecting_blocks_df <- st_make_valid(intersecting_blocks_df)

  return(intersecting_blocks_df)

}
flood_fill_algorithm <- function(spatial_data, num_seeds = 50, buffer_size = 10) {
    # Step 1: Select 50 random seed blocks
    seed_blocks <- select_random_rows(spatial_data, num_seeds)
    set.seed(10)
    # create a list of polygons called wards, one for each seed block
    wards <- vector("list", num_seeds)
    for (i in seq_along(wards)) {
        wards[[i]] <- st_geometry(seed_blocks[i,])
    }
    #create a df called occupied_blocks that contains the seed blocks
    occupied_blocks <- seed_blocks
    unoccupied_blocks <- spatial_data[!spatial_data$geoid10 %in% occupied_blocks$geoid10,]
    # Set up progress bar
    target <- nrow(unoccupied_blocks)
    pb <- txtProgressBar(min = 0, max = nrow(unoccupied_blocks), style = 3)

  # Keep growing the wards until almost blocks are occupied
    while (nrow(unoccupied_blocks) > 0) {
        skip_token <- 0
        for (i in seq_along(wards)) {
            adjacent_blocks <- find_adjacent_blocks_union(unoccupied_blocks, wards[[i]], buffer_size = buffer_size)

            if (nrow(adjacent_blocks) == 0) {
                #condition to avoid infinite loop
                skip_token <- skip_token + 1
                if (skip_token == num_seeds) {
                    return(wards)
                }
                next
            }

            selected_blocks <- select_random_rows(adjacent_blocks, num_rows = min(10, nrow(adjacent_blocks)))

            if (nrow(selected_blocks) > 10) {
                print("Error: selected_blocks > 10")
                return (wards)
            }
            #ensure that the selected blocks are valid geometries
            selected_blocks <- st_make_valid(selected_blocks)
            selected_blocks_geom <- st_union(selected_blocks)
            selected_blocks_geom <- st_make_valid(selected_blocks_geom)
            wards[[i]] <- st_make_valid(wards[[i]])
            wards[[i]] <- st_union(wards[[i]], st_geometry(selected_blocks_geom))

            if (length(wards[[i]]) > 1) {
                wards[[i]] <- st_union(wards[[i]])
            }

            occupied_blocks <- rbind(occupied_blocks, selected_blocks)
            unoccupied_blocks <- unoccupied_blocks[!unoccupied_blocks$geoid10 %in% selected_blocks$geoid10,]

            progress <- target - nrow(unoccupied_blocks)
            setTxtProgressBar(pb, progress)
        }
    }
close(pb)
ward_df <- as.data.frame(do.call(rbind, wards))
#change V1 to geometry, create new variable called ward_id that is the row number
ward_df <- ward_df %>% 
    rename(geometry = V1) %>% 
    mutate(ward_id = row_number())
#convert to sf
ward_df <- st_as_sf(ward_df)
return(ward_df)
}
iterated_adjacent_blocks <-function(spatial_data, selected_blocks, buffer_size, iterations) {
    for (i in 1:iterations) {
        if (i == 1) {
            start_df <- selected_blocks
            adjacent_df <- find_adjacent_blocks(spatial_data, selected_blocks, buffer_size = buffer_size)
            new_df <- rbind(adjacent_df, selected_blocks)
        } else {
            start_df <- new_df
            adjacent_df <- find_adjacent_blocks(spatial_data, adjacent_df, buffer_size = buffer_size)
            new_df <- rbind(adjacent_df, start_df)
        }
    }
    return(new_df)
}

# find_k_nearest_blocks <- function(spatial_data, selected_blocks, k = 5) {
#   nearest_blocks <- st_nearest_feature(spatial_data, selected_blocks, k = k)
#   nearest_blocks <- unlist(nearest_blocks)
#   nearest_blocks_df <- spatial_data[nearest_blocks, , drop = FALSE]
#   nearest_blocks_df <- nearest_blocks_df[!nearest_blocks_df$geoid10 %in% selected_blocks$geoid10,]
#   nearest_blocks_df <- nearest_blocks_df[!duplicated(nearest_blocks_df$geoid10),]

#   return(nearest_blocks_df)
# }