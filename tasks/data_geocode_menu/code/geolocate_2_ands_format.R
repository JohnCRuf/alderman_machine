library(tidyverse)
library(tidygeocoder)
source("geolocate_function.R")
df <- read_csv("../input/df_with_2_ands.csv")
#additional cleaning needed

geolocated_df <- menu_geolocate(df, "intersection_1", 100) %>%  #100 b/c of tougher geocoding.
    rename(lat_1 = lat, lon_1 = long, query_1 = query) %>%
    menu_geolocate(., "intersection_2", 100) %>% 
    rename(lat_2 = lat, lon_2 = long, query_2 = query)

write_csv(geolocated_df, "../output/geolocated_2_ands_df.csv")