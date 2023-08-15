library(tidyverse)
library(tidygeocoder)
source("geocode_function.R")
df <- read_csv("../input/menu_data_line.csv")

geocoded_df <- menu_geocode(df, "start_location", 1000) %>% 
    rename(lat_1= lat, lon_1 = long, query_1 = query) %>%
    menu_geocode(., "end_location", 1000) %>% 
    rename(lat_2 = lat, lon_2 = long, query_2 = query)

#replace all obviously non-Chicago coordinates with NA
geocoded_df <- filter_chicago_coordinates(geocoded_df)

write_csv(geocoded_df, "../output/geocoded_line_df.csv")