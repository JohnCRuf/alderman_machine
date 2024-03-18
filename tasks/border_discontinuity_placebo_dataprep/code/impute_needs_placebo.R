library(sf)
sf::sf_use_s2(FALSE) #disable s2 because it's not compatible with crappy ward maps
library(tidyverse)
library(units)
args <- commandArgs(trailingOnly = TRUE)

# Load ward map
ward_map <- readRDS(args[1])
#print out a map of the geometry
plot(ward_map$geometry)
model <- readRDS("../input/log_cubed_model.rds")
#impute ward needs from area
ward_map <- ward_map %>%
    mutate(area = st_area(geometry),
            area = set_units(area, mi^2)) %>%
    mutate( log_area = log(area),
            log_area_sq = log_area^2,
            log_area_cub = log_area^3)

#manipulate columns to correct format
ward_map <- ward_map %>%
    mutate(pct_of_needs = predict(model, newdata = ward_map))
ward_map <- ward_map %>%
    rename(ward_locate = ward_id)
ward_map <- ward_map %>%
    mutate(year_range = "2012-2022")
ward_map <- ward_map %>%
    st_drop_geometry() %>%
    select(ward_locate, year_range, pct_of_needs)

# save as csv
write_csv(ward_map, args[2])