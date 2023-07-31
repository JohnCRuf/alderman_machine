library(tidyverse)
library(tidygeocoder)
source("geolocate_function.R")
df <- read_csv("../input/and_dash_df.csv")
#additional cleaning needed

geolocated_df <- menu_geolocate_googleonly(df, "intersection_1", 10) %>%  #100 b/c of tougher geocoding.
    rename(lat_1 = lat, lon_1 = long, query_1 = query) %>%
    menu_geolocate_googleonly(., "intersection_2", 10) %>% 
    rename(lat_2 = lat, lon_2 = long, query_2 = query)

write_csv(geolocated_df, "../output/geolocated_and_dash_df.csv")