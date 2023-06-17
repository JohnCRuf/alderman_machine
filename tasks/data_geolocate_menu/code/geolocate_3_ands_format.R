library(tidyverse)
library(tidygeocoder)
source("geolocate_function.R")
df <- read_csv("../temp/df_with_3_ands.csv")
#filter to only rows with NA in intersection_1 2 3 and 4
df <- df %>% filter(is.na(intersection_1) & is.na(intersection_2) & is.na(intersection_3) & is.na(intersection_4))
#filter to first 100 rows
df <- df[1:100,]

geolocated_df <- menu_geolocate(df, "intersection_1", 10) %>% #rename lat lat_from_intersection
    rename(lat_1 = lat, lon_1 = long, query_1 = query) %>%
    menu_geolocate(., "intersection_2", 10) %>% #rename lat lat_to_intersection
    rename(lat_2 = lat, lon_2 = long, query_2 = query) %>%
    menu_geolocate(., "intersection_3", 10) %>% #rename lat lat_to_intersection
    rename(lat_3 = lat, lon_3 = long, query_3 = query) %>%
    menu_geolocate(., "intersection_4", 10) %>% #rename lat lat_to_intersection
    rename(lat_4 = lat, lon_4 = long, query_4 = query) %>%
 

write_csv(geolocated_df, "../temp/geolocated_from_to_df.csv")