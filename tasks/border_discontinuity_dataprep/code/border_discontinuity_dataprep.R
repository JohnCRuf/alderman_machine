library(sf)
library(dplyr)
library(sp)
source("../input/map_data_prep_fn.R")
source("compute_border_distances.R")

# Load needs data (assuming it's an .rda file)
needs_df <- load("../input/ward_pct_of_needs.rda")

# Load 2012-2022 map
map_2012 <- map_load("../temp/ward_precincts_2012_2022/ward_precincts_2012_2022.shp")

map_2012_distances <- compute_precinct_distances(map_2012)

# Load 2003-2011 map
map_2003 <- map_load("../temp/ward_precincts_2003_2011/ward_precincts_2003_2011.shp")

map_2003_distances <- compute_precinct_distances(map_2003)

# add indicator for which map the data is from
map_2003_distances$year <- "2003-2011"
map_2012_distances$year <- "2012-2022"

# rbind the two maps
# remove shape area and shape length columns from 2012
map_2012_distances <- map_2012_distances %>% select(-shape_area, -shape_len)
map_distances <- rbind(map_2003_distances, map_2012_distances)
