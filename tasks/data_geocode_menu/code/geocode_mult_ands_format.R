library(tidyverse)
library(tidygeocoder)
source("geolocate_function.R")
df <- read_csv("../input/df_with_mult_ands.csv")

geolocated_df <- menu_geolocate(df, "intersection_1", 100) %>%  #100 b/c of tougher geocoding.
    rename(lat_1 = lat, lon_1 = long, query_1 = query) %>%
    menu_geolocate(., "intersection_2", 100) %>% 
    rename(lat_2 = lat, lon_2 = long, query_2 = query) %>%
    menu_geolocate(., "intersection_3", 100) %>% 
    rename(lat_3 = lat, lon_3 = long, query_3 = query) %>%
    menu_geolocate(., "intersection_4", 100) %>%
    rename(lat_4 = lat, lon_4 = long, query_4 = query) %>%
    menu_geolocate(., "intersection_5", 100) %>%
    rename(lat_5 = lat, lon_5 = long, query_5 = query) 
 

write_csv(geolocated_df, "../output/geolocated_mult_ands_df.csv")