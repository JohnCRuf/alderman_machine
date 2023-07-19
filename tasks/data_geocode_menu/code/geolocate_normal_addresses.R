library(tidyverse)
library(tidygeocoder)
source("geolocate_function.R")

df <- read_csv("../input/normal_address_df.csv")
geolocated_df <- menu_geolocate(df, "address", 500)
write_csv(geolocated_df, "../output/geolocated_normal_address_df.csv")