library(sf)
library(tidyverse)
library(sp)
source("../input/map_data_prep_fn.R")
ARGS<- commandArgs(trailingOnly = TRUE) # nolint
# Load 2012-2022 map
map <- map_load(ARGS[1])

wards_map <- map %>%
    group_by(ward_locate) %>%
    summarise(geometry = st_union(geometry))

#save to rds
saveRDS(wards_map, ARGS[2])