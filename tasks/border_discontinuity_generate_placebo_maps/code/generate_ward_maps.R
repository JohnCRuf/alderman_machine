library(tidyverse)
library(sf)
library(assertthat)
source("flood_fill_functions.R")
#load args
args <- commandArgs(trailingOnly = TRUE)
seed <- as.numeric(args[1])
# Load map data
block_map_2010 <- readRDS("../input/block_map_2010.rds")

# Ensure valid geometries and set CRS
spatial_data <- st_make_valid(block_map_2010)
spatial_data <- st_set_crs(spatial_data, 4326)

#run the flood fill algorithm 30 times to create 30 placebo maps
#initialize a list to store the maps
set.seed(seed)
placebo_map <- flood_fill_algorithm(spatial_data, num_seeds = 50, buffer_size = 1.0001)

saveRDS(placebo_map, paste0("../output/placebo_map_", args[1], ".rds"))