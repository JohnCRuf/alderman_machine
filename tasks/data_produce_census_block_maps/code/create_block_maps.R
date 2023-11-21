library(sf)
library(tidyverse)
library(sp)
source("../input/map_data_prep_fn.R")
ARGS<- commandArgs(trailingOnly = TRUE) # nolint
# Load 2012-2022 map
map <- st_read(ARGS[1])
map <- st_transform(map, 4326)

#save to rds
saveRDS(map, ARGS[2])