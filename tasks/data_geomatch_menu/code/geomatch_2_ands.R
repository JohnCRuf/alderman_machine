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
df_line <- df_line %>% filter(!is.na(lat_2) & is.numeric(lat_2) & !is.na(lon_2) & is.numeric(lon_2))

#combine df_single_1 and df_single_2
df_single <- rbind(df_single_1, df_single_2)

#load 2003-2011 precinct shapefile
map_2003_2011 <- st_read("../temp/ward_precincts_2003_2011/ward_precincts_2003_2011.shp")
#rename WARD to ward_locate, PRECINCT to precinct_locate, and WARD_PRECI to ward_precinct_locate
map_2003_2011 <- map_2003_2011 %>% 
rename(ward_locate_2003 = WARD, 
precinct_locate_2003 = PRECINCT, 
ward_precinct_locate_2003 = WARD_PRECI)
map_2003_2011 <- st_transform(map_2003_2011, 4326)

map_2012_2022 <- st_read("../temp/ward_precincts_2012_2022/ward_precincts_2012_2022.shp")
#rename WARD to ward_locate, PRECINCT to precinct_locate, and WARD_PRECI to ward_precinct_locate
map_2012_2022 <- map_2012_2022 %>%
rename(ward_locate_2012 = WARD,
precinct_locate_2012 = PRECINCT,
ward_precinct_locate_2012 = WARD_PRECI)
map_2012_2022 <- st_transform(map_2012_2022, 4326)

#feed single addresses into geomatch_single_coordinate
df_matched_single <-geomatch_single_coordinate(df_single, map_2003_2011, 4326)
df_matched_single <- geomatch_single_coordinate(df_matched_single, map_2012_2022, 4326)
write_csv(df_single, "../output/geomatched_2_ands_singles.csv")

#now mutate and geomatch df_line
df_line <- df_line %>% mutate(id = 1:nrow(df_line))
df_line_sf <- create_sf_lines(df_line, "lat_1", "lon_1", "lat_2", "lon_2", 4326)

df_line_matched <- geomatch_lines(df_line_sf, map_2003_2011, 200)
df_line_matched <- df_line_matched %>%
 mutate(total_length_2003 = as.double(total_length),
        intersect_length_2003 = as.double(intersect_length)) %>%
 arrange(desc(total_length_2003)) %>%
 select(-total_length, -intersect_length) 
df_line_matched <- geomatch_lines(df_line_matched, map_2012_2022, 200)
df_line_matched <- df_line_matched %>%
 mutate(total_length_2012 = as.double(total_length),
        intersect_length_2012 = as.double(intersect_length)) %>%
 arrange(desc(total_length_2012)) %>%
 select(-total_length, -intersect_length) 
write_csv(df_line_matched, "../output/geomatched_2_ands_df_lines.csv")