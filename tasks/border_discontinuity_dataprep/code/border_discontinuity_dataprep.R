library(sf)
sf::sf_use_s2(FALSE) #disable s2 because it's not compatible with crappy ward maps
library(dplyr)
library(sp)
library(units)
source("../input/map_data_prep_fn.R")
source("compute_border_distances.R")

# Load 2012-2022 map
ward_map_2012 <- readRDS("../input/ward_map_2012_2022.rds")
block_map_2012 <- readRDS("../input/block_map_2010.rds")
#merge by maximum intersection
block_map_2012 <- st_intersection(block_map_2012, ward_map_2012)
block_map_2012$intersect_area <- st_area(block_map_2012)
block_map_2012 <- block_map_2012 %>% 
  group_by(tract_bloc) %>% 
  filter(intersect_area > set_units(0,m^2)) %>%
  filter(intersect_area == max(intersect_area)) %>% 
  ungroup() %>%
  select(tract_bloc, ward_locate,geometry)

#rename ward_locate to ward
block_map_2012 <- block_map_2012 %>% 
  rename(ward = ward_locate)

map_2012_distances <- compute_area_to_ward_distances(block_map_2012, ward_map_2012)
#immediately write to RDS
# saveRDS(map_2012_distances, "../output/map_2012_distances.rds")
map_2012_distances <- readRDS("../output/map_2012_distances.rds")

#load needs data
needs_df <- read.csv("../input/ward_needs_data.csv")
#rename year map
needs_df <- needs_df %>% 
  rename(map = year_range) %>%
  rename(ward = ward_locate)
#filter to 2012 map
needs_df <- needs_df %>% 
  filter(map == "2012-2022")
#join by map and ward_locate
map_distances_needs <- map_2012_distances %>% 
  left_join(needs_df, by = c("ward")) 


#load 2012-2022 spending data
spending_2012_2022 <- read.csv("../input/block_menu_panel_2012_2022.csv")

spending <- spending_2012_2022 %>% 
  filter(cycle != "2004-2007" & cycle != "2008-2011")
spending$tract_bloc <- as.character(spending$tract_bloc)

list_tracts <- unique(spending$tract_bloc)
list_tracts_map <- unique(block_map_2012$tract_bloc)
#create disjoint set of two
list_tracts_not_in_map <- list_tracts[!list_tracts %in% list_tracts_map]
#join spending data to map distances and needs data
map_distances_needs_spending <- map_distances_needs %>% 
  left_join(spending, by = c( "tract_bloc"))
#remove geometry using sf
map_distances_needs_spending <- st_drop_geometry(map_distances_needs_spending)
#rename pct_of_needs to pct_of_needs_home
map_distances_needs_spending <- map_distances_needs_spending %>% 
  rename(pct_of_needs_home = pct_of_needs)
#join to needs data using nearest ward
#convert nearest_ward to integer
map_distances_needs_spending$nearest_ward <- as.integer(map_distances_needs_spending$nearest_ward)
map_distances_needs_spending <- map_distances_needs_spending %>% 
  left_join(needs_df, by = c("map", "nearest_ward" = "ward"))
#rename pct_of_needs to pct_of_needs_nearest
map_distances_needs_spending <- map_distances_needs_spending %>% 
  rename(pct_of_needs_nearest = pct_of_needs)

#create a new dataframe called ward_cycle_totals which is the total weighted_cost by ward_locate and cycle
#merge spending with block_map_2012 to get ward_locate
#remove geometry using sf
block_map_merge <- st_drop_geometry(block_map_2012) %>%
  select(tract_bloc, ward)
#list tracts in spending that are not in block_map_merge
df_list <- spending %>% 
  filter(!tract_bloc %in% unique(block_map_merge$tract_bloc))


spending <- spending %>% 
  left_join(block_map_merge, by = c("tract_bloc"))
#count number of repeated tract_blocs
spending <- spending %>% 
  group_by(tract_bloc) %>% 
  mutate(n = n()) %>% 
  ungroup()
ward_cycle_totals <- spending %>% 
  group_by(ward, cycle) %>% 
  summarize(total_wardlocate_spending = sum(weighted_cost))
#what is sum of ward_cycle_totals?
sum(ward_cycle_totals$total_wardlocate_spending)
#join to map_distances_needs_spending
map_distances_needs_spending <- map_distances_needs_spending %>% 
  left_join(ward_cycle_totals, by = c("ward", "cycle"))
#write to csv
write.csv(map_distances_needs_spending, "../output/border_discontinuity_data.csv", row.names = FALSE)