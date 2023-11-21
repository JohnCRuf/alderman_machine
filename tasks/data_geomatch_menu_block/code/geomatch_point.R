library(tidyverse)
library(sp)
library(rgdal)
library(lwgeom)
library(sf)
sf::sf_use_s2(FALSE) #turn off s2 because it is not compatible with old chicago shapefiles
source("geomatch_points_fn.R")
ARGS<- commandArgs(trailingOnly = TRUE)
data <- read_csv("../input/geocoded_point_df.csv")

#remove cases where variables "lat" or "long" are NA or not numeric
data <- data %>% filter(!is.na(lat) & is.numeric(lat) & !is.na(long) & is.numeric(long))

#load either 2003-2011 or 2012-2022 precinct shapefile
map <- readRDS("../input/block_map_2000.rds")

#feed single addresses into geomatch_single_coordinate
df_matched <-geomatch_single_coordinate(data, map, 4326)
write_csv(df_matched, ARGS[2])
