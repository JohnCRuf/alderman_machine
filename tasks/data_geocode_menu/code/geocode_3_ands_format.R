library(tidyverse)
library(tidygeocoder)
source("geocode_function.R")
df <- read_csv("../input/df_with_3_ands.csv")

geocoded_df <- menu_geocode(df, "intersection_1", 100) %>%  #100 b/c of tougher geocoding.
    rename(lat_1 = lat, lon_1 = long, query_1 = query) %>%
    menu_geocode(., "intersection_2", 100) %>% 
    rename(lat_2 = lat, lon_2 = long, query_2 = query) %>%
    menu_geocode(., "intersection_3", 100) %>% 
    rename(lat_3 = lat, lon_3 = long, query_3 = query) %>%
    menu_geocode(., "intersection_4", 100) %>%
    rename(lat_4 = lat, lon_4 = long, query_4 = query) 
 
#replace all obviously non-Chicago coordinates with NA
geocoded_df <- filter_chicago_coordinates(geocoded_df)

write_csv(geocoded_df, "../output/geocoded_3_ands_df.csv")