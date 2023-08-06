library(tidyverse)
library(tidygeocoder)
source("geocode_function.R")
df <- read_csv("../input/and_dash_df.csv")
#additional cleaning needed

geocoded_df <- menu_geocode_googleonly(df, "intersection_1", 10) %>%  #100 b/c of tougher geocoding.
    rename(lat_1 = lat, lon_1 = long, query_1 = query) %>%
    menu_geocode_googleonly(., "intersection_2", 10) %>% 
    rename(lat_2 = lat, lon_2 = long, query_2 = query)
#replace all obviously non-Chicago coordinates with NA
geocoded_df <- filter_chicago_coordinates(geocoded_df)

write_csv(geocoded_df, "../output/geocoded_and_dash_df.csv")