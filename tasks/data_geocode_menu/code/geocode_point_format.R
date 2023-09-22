library(tidyverse)
library(tidygeocoder)
source("geocode_function.R")
df <- read_csv("../input/menu_data_point.csv")
geocoded_df <- menu_geocode(df, "point_location", 1000)
#replace all obviously non-Chicago coordinates with NA
geocoded_df <- filter_chicago_coordinates(geocoded_df)
write_csv(geocoded_df, "../output/geocoded_point_df.csv")