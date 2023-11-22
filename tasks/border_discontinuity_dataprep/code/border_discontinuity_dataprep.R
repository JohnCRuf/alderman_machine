library(sf)
sf::sf_use_s2(FALSE) #disable s2 because it's not compatible with crappy ward maps
library(dplyr)
library(sp)
source("../input/map_data_prep_fn.R")
source("compute_border_distances.R")

# Load 2012-2022 map
ward_map_2012 <- readRDS("../input/ward_map_2012_2022.rds")
block_map_2012 <- readRDS("../input/block_map_2010.rds")
#sf merge within block_map and ward map, tell me what ward each block is within
block_map_2012 <- st_join(block_map_2012, ward_map_2012, join = st_within)
#remove blocks that are not in a ward
block_map_2012 <- block_map_2012 %>% 
  filter(!is.na(ward_locate))
#filter to first 100 rows
block_map_2012 <- block_map_2012 
map_2012_distances <- compute_area_to_ward_distances(block_map_2012, ward_map_2012)
#immediately write to RDS
writeRDS(map_2012_distances, "../output/map_2012_distances.rds")

#load needs data
needs_df <- read.csv("../input/ward_needs_data.csv")
#rename year map
needs_df <- needs_df %>% 
  rename(map = year_range)
#filter to 2012 map
needs_df <- needs_df %>% 
  filter(map == "2012-2022")
#join by map and ward_locate
map_distances_needs <- map_2012_distances %>% 
  left_join(needs_df, by = c("ward_locate")) 


#load 2012-2022 spending data
spending_2012_2022 <- read.csv("../input/block_menu_panel_2012_2022.csv")
spending <- spending_2012_2022 %>% 
  filter(cycle != "2004-2007" & cycle != "2008-2011")
spending$tract_bloc <- as.character(spending$tract_bloc)

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
  left_join(df, by = c("map", "nearest_ward" = "ward_locate"))
#rename pct_of_needs to pct_of_needs_nearest
map_distances_needs_spending <- map_distances_needs_spending %>% 
  rename(pct_of_needs_nearest = pct_of_needs)

#create a new dataframe called ward_cycle_totals which is the total weighted_cost by ward_locate and cycle
#merge spending with block_map_2012 to get ward_locate
spending <- spending %>% 
  left_join(block_map_2012, by = c("tract_bloc"))
ward_cycle_totals <- spending %>% 
  group_by(ward_locate, cycle) %>% 
  summarize(total_wardlocate_spending = sum(weighted_cost))
#join to map_distances_needs_spending
map_distances_needs_spending <- map_distances_needs_spending %>% 
  left_join(ward_cycle_totals, by = c("ward_locate", "cycle"))
#write to csv
write.csv(map_distances_needs_spending, "../output/border_discontinuity_data.csv", row.names = FALSE)