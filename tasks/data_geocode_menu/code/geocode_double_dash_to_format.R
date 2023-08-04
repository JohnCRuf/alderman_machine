library(tidyverse)
library(tidygeocoder)
source("geocode_function.R")
df <- read_csv("../input/double_dash_to_df.csv")

geocoded_df <- menu_geocode(df, "from_intersection", 500) %>% #rename lat lat_from_intersection
    rename(lat_from_intersection = lat, lon_from_intersection = long, query_from_intersection = query) %>%
    menu_geocode(., "to_intersection", 500) %>% #rename lat lat_to_intersection
    rename(lat_to_intersection = lat, lon_to_intersection = long, query_to_intersection = query) 

write_csv(geocoded_df, "../output/geocoded_double_dash_to_df.csv")