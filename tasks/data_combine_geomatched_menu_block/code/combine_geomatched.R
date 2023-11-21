library(tidyverse)
library(sf)
library(sp)
library(assertr)
library(assertthat)
ARGS<- commandArgs(trailingOnly = TRUE)
map_filename <- ARGS[2]
output_filename_rds <- paste0("../output/block_menu_panel_", ARGS[1], ".rds")
output_filename_csv <- paste0("../output/block_menu_panel_", ARGS[1], ".csv")
#load the map
map <- readRDS(map_filename)
#repeat the map for every cycle: 2004-2007, 2008-2011, 2012-2015, 2016-2019, 2020-2023
cycles <- c("2004-2007", "2008-2011", "2012-2015", "2016-2019", "2020-2023") 
map <- map %>% 
  crossing(cycle = cycles) %>%
  unnest(cols = c(cycle))
#for every argument, load the file, keep the ward, year ward_locate, precinct_locate, est_cost, and  total_length and intersect_length if it exists
df_append <- data.frame()
for (i in 3:length(ARGS)) {
  df <- read_csv(ARGS[i])
  print(ARGS[i])
  #if the file has a column called "total_length" and "intersect_length", 
  if ("total_length" %in% colnames(df) & "intersect_length" %in% colnames(df)) {
    df <- df %>%
      select( ward, year, tract_bloc, id, est_cost, total_length, intersect_length) %>%
      mutate(weight = intersect_length/total_length,
             shape_marker = "line") %>%
        select(-total_length, -intersect_length)
} else if ("total_area" %in% colnames(df) & "intersect_area" %in% colnames(df)) {
    df <- df %>%
      select( ward, year, tract_bloc, id, est_cost, total_area, intersect_area) %>%
      mutate(weight = intersect_area/total_area) %>%
      mutate(shape_marker = "area") %>%
      select(-total_area, -intersect_area)
  } else {
    df <- df %>%
      select( ward, year, tract_bloc, id, est_cost) %>%
      mutate(weight = 1,
             shape_marker = "point")
  }

  df_append <- rbind(df_append, df)
}

#group by id, and remove any id where ward_locate != ward more than 2 times
df_append <- df_append %>%
  mutate(ward_locate = as.character(tract_bloc)) %>%
  group_by(id) %>%
  ungroup()
#set cycles based off year
df_append <- df_append %>%
  mutate(cycle = case_when(
    year %in% 2004:2007 ~ "2004-2007",
    year %in% 2008:2011 ~ "2008-2011",
    year %in% 2012:2015 ~ "2012-2015",
    year %in% 2016:2019 ~ "2016-2019",
    year %in% 2020:2023 ~ "2020-2023"
  ))

#write current df_append to csv
write_csv(df_append, "../output/project_compiled_df.csv")
#TODO: I should probably include a version of this that doesn't drop the rows where ward_locate != ward

#assert that the sum of the weights for each id is 1
# df_assert <- df_append %>% 
#   group_by(id, shape_marker) %>%
#   summarize(weight_sum = sum(weight)) 
# assert_that(all(df_assert$weight_sum <= 1))

df_append <- df_append %>%
  mutate(weighted_cost = est_cost * weight)
#now group by ward_locate, precinct_locate, and year, and sum the weighted_cost
df_append <- df_append %>%
  group_by(tract_bloc, cycle) %>%
  summarise(weighted_cost = sum(weighted_cost)) %>%
  ungroup()
#now join left join the map to the df_append. All missing values of weighted_cost will be set to 0
final_df <- map %>%
  left_join(df_append, by = c("tract_bloc", "cycle")) %>%
  mutate(weighted_cost = ifelse(is.na(weighted_cost), 0, weighted_cost))
#write the final_df to a csv
saveRDS(final_df, file =output_filename_rds)
#remove geometry column and write to csv
final_df <- final_df %>%
  select(-geometry)
write_csv(final_df, output_filename_csv)