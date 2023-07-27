library(tidyverse)
library(sp)
library(rgdal)
library(lwgeom)
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
select(-lat_2, -lon_2, -query_2, -lat_1, -lon_1, -query_1)

df_single_2 <- df %>% filter(is.na(lat_2) | !is.numeric(lat_2) | is.na(lon_2) | !is.numeric(lon_2)) %>% 
mutate( lat = lat_1, 
        long = lon_1, 
        query = query_1) %>% 
select(-lat_1, -lon_1, -query_1, -lat_2, -lon_2, -query_2)

#remove either NA case from df to get df_line
df_line <- df %>% filter(!(is.na(lat_1) | !is.numeric(lat_1) | is.na(lon_1) | !is.numeric(lon_1))) 
#remove cases where lat_2 is NA or not numeric
df_line <- df_line %>% filter(!is.na(lat_2) & is.numeric(lat_2) & !is.na(lon_2) & is.numeric(lon_2))

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

#now mutate and geomatch df_line
df_line <- df_line %>% mutate(id = 1:nrow(df_line))
df_line_sf <- create_sf_lines(df_line, "lat_1", "lon_1", "lat_2", "lon_2", 4326)
#generate line length
df_line_sf <- df_line_sf %>% mutate(total_length = st_length(geometry))
#keep only 100 rows for testing
df_line_sf_test <- df_line_sf %>% filter(id <= 100)
map <- map_2003_2011 
lines <- df_line_sf_test

df_line_matched <- geomatch_lines(df_line_sf, map_2003_2011)
#convert total length to double
df_line_matched <- df_line_matched %>% mutate(total_length = as.double(total_length))
#filter to total length > 1000
df_line_matched <- df_line_matched %>% filter(total_length > 1000)