library(sf)
library(dplyr)
library(sp)
source("../input/map_data_prep_fn.R")
source("compute_border_distances.R")

# Load 2012-2022 map
map_2012 <- map_load("../temp/ward_precincts_2012_2022/ward_precincts_2012_2022.shp")

map_2012_distances <- compute_precinct_distances(map_2012)

# Load 2003-2011 map
map_2003 <- map_load("../temp/ward_precincts_2003_2011/ward_precincts_2003_2011.shp")

map_2003_distances <- compute_precinct_distances(map_2003)

# add indicator for which map the data is from
map_2003_distances$map <- "2003-2011"
map_2012_distances$map <- "2012-2022"

# rbind the two maps
# remove shape area and shape length columns from 2012
map_2012_distances <- map_2012_distances %>% 
  select(-shape_area, -shape_len)
map_distances <- rbind(map_2003_distances, map_2012_distances)

#load needs data
df <- read.csv("../input/ward_needs_data.csv")
#rename year map
df <- df %>% 
  rename(map = year_range)
#join by map and ward_locate
map_distances_needs <- map_distances %>% 
  left_join(df, by = c("map", "ward_locate")) 

#load spending data
spending_2003_2011 <- read.csv("../input/ward_precinct_menu_panel_2003_2011.csv")
#if year is between 2003 and 2007, set cycle to 2003-2007. If year is between 2008 and 2011, set cycle to 2008-2011
spending_2003_2011$cycle <- ifelse(spending_2003_2011$year %in% 2003:2007, "2003-2007", "2008-2011")
#drop if year > 2012
spending_2003_2011 <- spending_2003_2011 %>% 
  filter(year <= 2012)
#summarize by cycle, ward locate, precinct locate, and weighted_cost
spending_2003_2011 <- spending_2003_2011 %>% 
  group_by(cycle, ward_locate, precinct_locate) %>% 
  summarize(weighted_cost = sum(weighted_cost))

#load 2012-2022 spending data
spending_2012_2022 <- read.csv("../input/ward_precinct_menu_panel_2012_2022.csv")
#if year is between 2012 and 2015, set cycle to 2012-2015. If year is between 2016 and 2022, set cycle to 2016-2019, if year>2019 set cycle to 2020-2023
spending_2012_2022$cycle <- ifelse(spending_2012_2022$year %in% 2012:2015, "2012-2015", ifelse(spending_2012_2022$year %in% 2016:2019, "2016-2019", "2020-2023"))
#drop if year<2012
spending_2012_2022 <- spending_2012_2022 %>% 
  filter(year >= 2012)
#summarize by cycle, ward locate, precinct locate, and weighted_cost
spending_2012_2022 <- spending_2012_2022 %>% 
  group_by(cycle, ward_locate, precinct_locate) %>% 
  summarize(weighted_cost = sum(weighted_cost))
#rbind spending data
spending <- rbind(spending_2003_2011, spending_2012_2022)
#create a column for the map based on cycle
spending$map <- ifelse(spending$cycle %in% c("2003-2007", "2008-2011"), "2003-2011", "2012-2022")

#join spending data to map distances and needs data
map_distances_needs_spending <- map_distances_needs %>% 
  left_join(spending, by = c("map", "ward_locate", "precinct_locate"))
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
ward_cycle_totals <- spending %>% 
  group_by(ward_locate, cycle) %>% 
  summarize(total_wardlocate_spending = sum(weighted_cost))
#join to map_distances_needs_spending
map_distances_needs_spending <- map_distances_needs_spending %>% 
  left_join(ward_cycle_totals, by = c("ward_locate", "cycle"))
#write to csv
write.csv(map_distances_needs_spending, "../output/border_discontinuity_data.csv", row.names = FALSE)