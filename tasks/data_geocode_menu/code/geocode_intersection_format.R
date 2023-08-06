library(tidyverse)
library(tidygeocoder)
source("geocode_function.R")
df <- read_csv("../input/intersection_df.csv")
geocoded_df <- menu_geocode(df, "location", 500)
#replace all obviously non-Chicago coordinates with NA
geocoded_df <- filter_chicago_coordinates(geocoded_df)
write_csv(geocoded_df, "../output/geocoded_intersection_df.csv")