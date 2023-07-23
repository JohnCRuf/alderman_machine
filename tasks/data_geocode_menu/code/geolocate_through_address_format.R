library(tidyverse)
library(tidygeocoder)
source("geolocate_function.R")
df <- read_csv("../input/through_address_df.csv")
#additional cleaning needed

geolocated_df <- menu_geolocate(df, "start", 100) %>%  #100 b/c of tougher geocoding.
    rename(lat_1 = lat, lon_1 = long, query_1 = query) %>%
    menu_geolocate(., "end", 10) %>% 
    rename(lat_2 = lat, lon_2 = long, query_2 = query) 
write_csv(geolocated_df, "../output/geolocated_through_address_df.csv")