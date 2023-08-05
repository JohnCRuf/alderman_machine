library(tidyverse)
library(sp)
library(rgdal)
library(lwgeom)
library(sf)
source("geomatch_points_fn.R")
source("geomatch_lines_fn.R")
source("map_data_prep_fn.R")
ARGS<- commandArgs(trailingOnly = TRUE)
df <- read_csv("../input/geocoded_2_ands_df.csv")


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

#load either 2003-2011 or 2012-2022 precinct shapefile
map <- map_load(ARGS[1])

#feed single addresses into geomatch_single_coordinate
df_matched_single <-geomatch_single_coordinate(df_single, map, 4326)
write_csv(df_single, ARGS[2])

#now mutate and geomatch df_line
df_line <- df_line %>% mutate(id = 1:nrow(df_line))
df_line_sf <- create_sf_lines(df_line, "lat_1", "lon_1", "lat_2", "lon_2", 4326)

df_line_matched <- geomatch_lines(df_line_sf, map, 200)
df_line_matched <- df_line_matched %>%
 mutate(total_length = as.double(total_length),
        intersect_length = as.double(intersect_length)) %>%
 arrange(desc(total_length)) %>%
 select(-total_length, -intersect_length) 
write_csv(df_line_matched, ARGS[3])