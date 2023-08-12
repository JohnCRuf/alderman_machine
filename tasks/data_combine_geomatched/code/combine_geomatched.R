library(tidyverse)
library(sf)
library(sp)
library(assertr)
source("../input/map_data_prep_fn.R")
ARGS<- commandArgs(trailingOnly = TRUE)
map_filename <- paste0("../temp/ward_precincts_", ARGS[1], "/ward_precincts_", ARGS[1], ".shp")
output_filename_rds <- paste0("../output/ward_precinct_menu_panel_", ARGS[1], ".rds")
output_filename_csv <- paste0("../output/ward_precinct_menu_panel_", ARGS[1], ".csv")
#load the map
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
#for every argument, load the file, keep the location, ward, year ward_locate, precinct_locate, est_cost, and  total_length and intersect_length if it exists
df_append <- data.frame()
for (i in 2:length(ARGS)) {
  df <- read_csv(ARGS[i])
  print(ARGS[i])
  #if the file has a column called "total_length" and "intersect_length", 
  if ("total_length" %in% colnames(df) & "intersect_length" %in% colnames(df)) {
    df <- df %>%
      select(location, ward, year, ward_locate, precinct_locate, id, est_cost, total_length, intersect_length) %>%
      mutate(weight = intersect_length/total_length) %>%
        select(-total_length, -intersect_length)
} else if ("total_area" %in% colnames(df) & "intersect_area" %in% colnames(df)) {
    df <- df %>%
      select(location, ward, year, ward_locate, precinct_locate, id, est_cost, total_area, intersect_area) %>%
      mutate(weight = intersect_area/total_area) %>%
      select(-total_area, -intersect_area)
  } else {
    df <- df %>%
      select(location, ward, year, ward_locate, precinct_locate, id, est_cost) %>%
      mutate(weight = 1)
  }

  df_append <- rbind(df_append, df)
}

#group by id, and remove any id where ward_locate != ward more than 2 times
df_append <- df_append %>%
  group_by(id) %>%
  mutate(ward_locate = as.character(ward_locate),
        precinct_locate = as.character(precinct_locate)) %>%
  filter(sum(ward_locate != ward) <= 2) %>%
  ungroup()
#remove any rows where ward_locate != ward, this implicitly sets "gifts" between wards to 0
df_append <- df_append %>%
  filter(ward_locate == ward) 
#TODO: I should probably include a version of this that doesn't drop the rows where ward_locate != ward
#now create a new variable called weighted_cost, which is the est_cost * weight
df_append <- df_append %>%
  mutate(weighted_cost = est_cost * weight)
#now group by ward_locate, precinct_locate, and year, and sum the weighted_cost
df_append <- df_append %>%
  group_by(ward_locate, precinct_locate, year) %>%
  summarise(weighted_cost = sum(weighted_cost)) %>%
  ungroup()
#now join left join the map to the df_append. All missing values of weighted_cost will be set to 0
final_df <- map %>%
  left_join(df_append, by = c("ward_locate", "precinct_locate", "year")) %>%
  mutate(weighted_cost = ifelse(is.na(weighted_cost), 0, weighted_cost))
#write the final_df to a csv
saveRDS(final_df, file =output_filename_rds)
#remove geometry column and write to csv
final_df <- final_df %>%
  select(-geometry)
write_csv(final_df, output_filename_csv)