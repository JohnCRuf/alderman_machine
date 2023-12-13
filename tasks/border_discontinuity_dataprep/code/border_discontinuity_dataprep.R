library(sf)
sf::sf_use_s2(FALSE) #disable s2 because it's not compatible with crappy ward maps
library(dplyr)
library(sp)
library(units)
library(assertthat)
source("../input/map_data_prep_fn.R")
source("compute_border_distances.R")

ward_map_2012 <- readRDS("../input/ward_map_2012_2022.rds")
block_map_2010 <- readRDS("../input/block_map_2010.rds")
block_map_2012 <- st_intersection(block_map_2010, ward_map_2012)
block_map_2012$intersect_area <- st_area(block_map_2012)
block_map_2012 <- block_map_2012 %>%
  group_by(tract_bloc) %>%
  filter(intersect_area > set_units(0, m^2)) %>%
  filter(intersect_area == max(intersect_area)) %>%
  ungroup() %>%
  select(tract_bloc, ward_locate,geometry)
assert_that(all(unique(block_map_2012$tract_bloc) %in% unique(block_map_2010$tract_bloc)))

block_map_2012 <- block_map_2012 %>%
  rename(ward = ward_locate)

map_2012_distances <- compute_area_to_ward_distances(block_map_2012, ward_map_2012)
immediately write to RDS
# saveRDS(map_2012_distances, "../output/map_2012_distances.rds")
# map_2012_distances <- readRDS("../output/map_2012_distances.rds")

needs_df <- read.csv("../input/ward_needs_data.csv")
needs_df <- needs_df %>% 
  rename(map = year_range) %>%
  rename(ward = ward_locate)
needs_df <- needs_df %>% 
  filter(map == "2012-2022")
map_distances_needs <- map_2012_distances %>%
  left_join(needs_df, by = c("ward"))  %>%
  st_drop_geometry()


#load 2012-2022 spending data
spending_2012_2022 <- readRDS("../input/block_menu_panel_2012_2022.rds")

spending <- spending_2012_2022 %>% 
  filter(cycle != "2004-2007" & cycle != "2008-2011")
assert_that(all(unique(spending$tract_bloc) %in% unique(block_map_2010$tract_bloc)))

map_distances_needs_spending <- map_distances_needs %>%
  left_join(spending, by = c( "tract_bloc"))
map_distances_needs_spending <- st_drop_geometry(map_distances_needs_spending)
map_distances_needs_spending <- map_distances_needs_spending %>%
  rename(pct_of_needs_home = pct_of_needs)
map_distances_needs_spending$nearest_ward <- as.integer(map_distances_needs_spending$nearest_ward)
map_distances_needs_spending <- map_distances_needs_spending %>%
  left_join(needs_df, by = c("map", "nearest_ward" = "ward"))
map_distances_needs_spending <- map_distances_needs_spending %>%
  rename(pct_of_needs_nearest = pct_of_needs)
block_map_merge <- st_drop_geometry(block_map_2012) %>%
  select(tract_bloc, ward)


spending <- spending %>% 
  left_join(block_map_merge, by = c("tract_bloc"))
ward_cycle_totals <- spending %>% 
  group_by(ward, cycle) %>% 
  summarize(total_wardlocate_spending = sum(weighted_cost))
map_distances_needs_spending <- map_distances_needs_spending %>% 
  left_join(ward_cycle_totals, by = c("ward", "cycle"))
#drop geometry column
map_distances_needs_spending <- st_drop_geometry(map_distances_needs_spending) %>%
  select(-geometry)
#assert that no columnns start with "geom"
assert_that(all(!grepl("geom", colnames(map_distances_needs_spending))))
write.csv(map_distances_needs_spending, "../output/border_discontinuity_data.csv", row.names = FALSE)