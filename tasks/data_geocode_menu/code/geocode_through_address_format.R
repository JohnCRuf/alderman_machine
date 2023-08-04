library(tidyverse)
library(tidygeocoder)
source("geocode_function.R")
df <- read_csv("../input/through_address_df.csv")
#additional cleaning needed

geocoded_df <- menu_geocode(df, "start_address", 50) %>%  #50 b/c of tougher geocoding.
    rename(lat_1 = lat, lon_1 = long, query_1 = query) %>%
    menu_geocode(., "end_address", 50) %>% 
    rename(lat_2 = lat, lon_2 = long, query_2 = query) 
write_csv(geocoded_df, "../output/geocoded_through_address_df.csv")