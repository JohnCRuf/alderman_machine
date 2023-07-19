library(tidyverse)
library(tidygeocoder)
source("geolocate_function.R")
df <- read_csv("../temp/double_dash_to_df.csv")

geolocated_df <- menu_geolocate(df, "from_intersection", 500) %>% #rename lat lat_from_intersection
    rename(lat_from_intersection = lat, lon_from_intersection = long, query_from_intersection = query) %>%
    menu_geolocate(., "to_intersection", 500) %>% #rename lat lat_to_intersection
    rename(lat_to_intersection = lat, lon_to_intersection = long, query_to_intersection = query) 

write_csv(geolocated_df, "../temp/geolocated_double_dash_df.csv")