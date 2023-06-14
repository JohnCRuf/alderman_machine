library(tidyverse)
library(tidygeocoder)
source("geolocate_function.R")
#import ../temp/norm_address_df.csv as df
df <- read_csv("../temp/school_park_df.csv")
geolocated_df <- menu_geolocate(df, "school_park_name", 500)
write_csv(geolocated_df, "../temp/geolocated_school_park_df.csv")