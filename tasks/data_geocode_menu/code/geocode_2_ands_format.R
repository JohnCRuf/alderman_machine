library(tidyverse)
library(tidygeocoder)
source("geocode_function.R")
df <- read_csv("../input/df_with_2_ands.csv")
#additional cleaning needed

geocoded_df <- menu_geocode_googleonly(df, "intersection_1", 100) %>%  #100 b/c of tougher geocoding.
    rename(lat_1 = lat, lon_1 = long, query_1 = query) %>%
    menu_geocode_googleonly(., "intersection_2", 100) %>% 
    rename(lat_2 = lat, lon_2 = long, query_2 = query)
#replace all obviously non-Chicago coordinates with NA
geocoded_df <- filter_chicago_coordinates(geocoded_df)

write_csv(geocoded_df, "../output/geocoded_2_ands_df.csv")