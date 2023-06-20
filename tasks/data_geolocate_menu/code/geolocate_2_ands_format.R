library(tidyverse)
library(tidygeocoder)
source("geolocate_function.R")
df <- read_csv("../temp/df_with_2_ands.csv")
#additional cleaning needed

geolocated_df <- menu_geolocate(df, "location_1", 100) %>%  #100 b/c of tougher geocoding.
    rename(lat_1 = lat, lon_1 = long, query_1 = query) %>%
    menu_geolocate(., "location_2", 10) %>% 
    rename(lat_2 = lat, lon_2 = long, query_2 = query) %>%
    menu_geolocate(., "location_3", 10) %>% 
    rename(lat_3 = lat, lon_3 = long, query_3 = query) 

write_csv(geolocated_df, "../temp/geolocated_from_to_df.csv")