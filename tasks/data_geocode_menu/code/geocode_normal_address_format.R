library(tidyverse)
library(tidygeocoder)
source("geocode_function.R")

df <- read_csv("../input/normal_address_df.csv")
geocoded_df <- menu_geocode(df, "address", 500)
write_csv(geocoded_df, "../output/geocoded_normal_address_df.csv")