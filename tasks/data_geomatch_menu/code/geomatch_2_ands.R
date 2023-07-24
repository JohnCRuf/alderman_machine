library(tidyverse)
library(sp)
library(rgdal)
library(sf)
source("geomatch_single_coordinate_fn.R")
source("geomatch_lines_fn.R")
df <- read_csv("../input/geolocated_2_ands_df.csv")

#remove cases where both lat_1 and lat_2 are NA
df <- df %>% filter(!(is.na(lat_1) & is.na(lat_2)))
#filter to cases where either lat_1 or lat_2 is NA or not numeric
df_single_1 <- df %>% filter(is.na(lat_1) | !is.numeric(lat_1) | is.na(lon_1) | !is.numeric(lon_1)) %>%
mutate( lat = lat_2, 
        long = lon_2, 
        query = query_2) %>%
select(-lat_2, -lon_2, -query_2)

df_single_2 <- df %>% filter(is.na(lat_2) | !is.numeric(lat_2) | is.na(lon_2) | !is.numeric(lon_2)) %>% 
mutate( lat = lat_1, 
        long = lon_1, 
        query = query_1) %>% 
select(-lat_1, -lon_1, -query_1)

#combine df_single_1 and df_single_2
df_single <- rbind(df_single_1, df_single_2)

#load 2003-2011 precinct shapefile
map_2003_2011 <- st_read("../temp/ward_precincts_2003_2011/WardPrecincts.shp")
#rename WARD to ward_locate, PRECINCT to precinct_locate, and WARD_PRECI to ward_precinct_locate
map_2003_2011 <- map_2003_2011 %>% 
rename(ward_locate = WARD, 
precinct_locate = PRECINCT, 
ward_precinct_locate = WARD_PRECI)
map_2003_2011 <- st_transform(map_2003_2011, 4326)

#feed single addresses into geomatch_single_coordinate
df_matched_single <-geomatch_single_coordinate(df_single, map_2003_2011, 4326)
write_csv(df_single, "../output/geomatched_2_ands_singles.csv")

df_matched_combined <- geomatch_lines()
