library(tidyverse)
library(sf)
library(sp)
library(assertr)
library(assertthat)
source("../input/map_data_prep_fn.R")
ARGS<- commandArgs(trailingOnly = TRUE)

#apply arguments
input_filename <- ARGS[1]
map_filename <- paste0("../temp/ward_precincts_", ARGS[2], "/ward_precincts_", ARGS[2], ".shp")
output_filename <- ARGS[3]


map <- map_load(map_filename)
#repeat the map every year from 2003 to 2022
map <- map %>% 
  crossing(year = 2003:2022) %>%
  unnest(cols = c(year))
#change ward_locate and precinct_locate to double
map <- map %>%
  mutate(ward_locate = as.character(ward_locate),
         precinct_locate = as.character(precinct_locate))
#drop the 0th ward
map <- map %>%
  filter(ward_locate != "0")
#load the input file
df <- read_csv(input_filename)

df <- df %>%
  mutate(RcvdDate = as.Date(RcvdDate, format = "%m/%d/%Y"),
         year = year(RcvdDate),
         ward_locate = as.character(ward_locate),
         precinct_locate = as.character(precinct_locate))

df <- df %>%
  group_by(ward_locate, precinct_locate, year) %>%
  summarise(total_contribution = sum(Amount)) %>%
  ungroup()
#now join left join the map to the df. All missing values of contributions will be set to 0
final_df <- map %>%
  left_join(df, by = c("ward_locate", "precinct_locate", "year")) %>%
  mutate(total_contribution = ifelse(is.na(total_contribution), 0, total_contribution))
saveRDS(final_df, file =output_filename)
