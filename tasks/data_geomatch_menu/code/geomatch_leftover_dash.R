library(tidyverse)
library(sp)
library(rgdal)
library(lwgeom)
library(sf)
source("geomatch_points_fn.R")
source("geomatch_lines_fn.R")
source("map_data_prep_fn.R")
source("geomatch_data_prep_fns.R")
ARGS<- commandArgs(trailingOnly = TRUE)
df <- read_csv("../input/leftover_dash.csv")
#load either 2003-2011 or 2012-2022 precinct shapefile
map <- map_load(ARGS[1])

#filter to cases where df only has one unique lat-lon pair
df_points<- unique_pairs_filter(df, 1, GEQ = FALSE)

#feed single addresses into geomatch_single_coordinate
df_matched_single <-geomatch_single_coordinate(df_points, map, 4326)
write_csv(df_points, ARGS[2])

#now mutate and geomatch df_line
df_line <- unique_pairs_filter(df, 2, GEQ = FALSE)
df_line_sf <- create_sf_lines(df_line, "lat_1", "lon_1", "lat_2", "lon_2", 4326)

df_line_matched <- geomatch_lines(df_line_sf, map, 200)
df_line_matched <- df_line_matched %>%
 mutate(total_length = as.double(total_length),
        intersect_length = as.double(intersect_length)) %>%
 arrange(desc(total_length)) 
 
write_csv(df_line_matched, ARGS[3])