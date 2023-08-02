library(tidyverse)
library(sp)
library(rgdal)
library(lwgeom)
library(sf)
source("geomatch_points_fn.R")
source("map_data_prep_fn.R")
ARGS<- commandArgs(trailingOnly = TRUE)
# ARGS <- c("../temp/ward_precincts_2003_2011/ward_precincts_2003_2011.shp", "../output/geomatch_test.csv")
df <- read_csv("../input/geocoded_intersection_df.csv")

#remove cases where variables "lat" or "long" are NA or not numeric
df <- df %>% filter(!is.na(lat) & is.numeric(lat) & !is.na(long) & is.numeric(long))

#load either 2003-2011 or 2012-2022 precinct shapefile
map <- map_load(ARGS[1])

#feed single addresses into geomatch_single_coordinate
df_matched <-geomatch_single_coordinate(df, map, 4326)
write_csv(df_matched, ARGS[2])
