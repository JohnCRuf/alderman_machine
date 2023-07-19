library(tidyverse)
library(tidygeocoder)
source("geolocate_function.R")
#import ../temp/norm_address_df.csv as df
df <- read_csv("../temp/normal_address_df.csv")
geolocated_df <- menu_geolocate(df, "address", 500)
write_csv(geolocated_df, "../temp/geolocated_normal_address_df.csv")