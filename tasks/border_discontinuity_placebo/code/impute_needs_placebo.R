library(sf)
sf::sf_use_s2(FALSE) #disable s2 because it's not compatible with crappy ward maps
library(tidyverse)
args <- commandArgs(trailingOnly = TRUE)

# Load ward map
ward_map <- readRDS(args[1])
model <- readRDS("../input/log_cubed_model.rds")
#impute ward needs from area
ward_map <- ward_map %>%
    mutate(ward_area = st_area(geometry)) %>%
    mutate(ward_needs = predict(model, ward_area))
# save as rds in temp folder
saveRDS(ward_map, args[2])