library(sf)
sf::sf_use_s2(FALSE) #disable s2 because it's not compatible with crappy ward maps
library(tidyverse)
library(rmapshaper)
args <- commandArgs(trailingOnly = TRUE)

# Load ward map
ward_map <- readRDS(args[1])
#smooth ward map
ward_map <- ms_simplify(ward_map, keep = 0.01)
# save as rds in temp folder
saveRDS(ward_map, args[2])