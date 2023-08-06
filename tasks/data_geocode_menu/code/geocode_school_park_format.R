library(tidyverse)
library(tidygeocoder)
source("geocode_function.R")
#import ../temp/norm_address_df.csv as df
df <- read_csv("../input/school_park_df.csv")
geocoded_df <- menu_geocode(df, "school_park_name", 10)
#replace all obviously non-Chicago coordinates with NA
geocoded_df <- filter_chicago_coordinates(geocoded_df)
write_csv(geocoded_df, "../output/geocoded_school_park_df.csv")