library(tidyverse)
library(tidygeocoder)
source("geocode_function.R")
df <- read_csv("../input/double_dash_to_df.csv")

geocoded_df <- menu_geocode(df, "from_intersection", 500) %>% #rename lat lat_from_intersection
    rename(lat_1 = lat, lon_1 = long, query_1 = query) %>%
    menu_geocode(., "to_intersection", 500) %>% #rename lat lat_to_intersection
    rename(lat_2 = lat, lon_2 = long, query_2 = query) 

write_csv(geocoded_df, "../output/geocoded_double_dash_to_df.csv")