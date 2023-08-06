library(tidyverse)
library(tidygeocoder)
source("geocode_function.R")
df <- read_csv("../input/from_to_df.csv")

geocoded_df <- menu_geocode(df, "from_intersection", 500) %>% 
    rename(lat_1= lat, lon_1 = long, query_1 = query) %>%
    menu_geocode(., "to_intersection", 500) %>% 
    rename(lat_2 = lat, lon_2 = long, query_2 = query) %>%
    select(-from_street, -to_street, -main_street)

#replace all obviously non-Chicago coordinates with NA
geocoded_df <- filter_chicago_coordinates(geocoded_df)

write_csv(geocoded_df, "../output/geocoded_from_to_df.csv")