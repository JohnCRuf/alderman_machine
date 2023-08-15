library(tidyverse)
library(sf)
# Read and clean data
election_data <- read.csv("../input/incumbent_challenger_voteshare_df_precinct_level.csv") 

menu_data <- readRDS("../input/ward_precinct_menu_panel_2003_2011.rds")

#drop observations of election data where year is greater than 2011 and ward != 50
election_data <- election_data %>%
  filter(year >= 2011, ward == 50, year <= 2015) %>% 
    mutate(ward = as.character(ward),
          precinct = as.character(precinct),
          year = as.character(year),
          type = case_when(type == "General" ~ "general",
                           type == "Runoff" ~ "runoff"))

#drop observations of menu data where year is greater than 2011 and ward != 50
menu_data <- menu_data %>%
  filter(year >= 2011, ward_locate == 50, year <= 2014)

#take total spending by precinct
total_spending <- menu_data %>%
  group_by(ward_locate, precinct_locate, geometry) %>%
  summarise(total_spending = sum(weighted_cost)) %>%
  ungroup()
#rename ward_locate and precinct_locate to ward and precinct
total_spending <- total_spending %>%
  rename(ward = ward_locate,
         precinct = precinct_locate)
#merge total spending with election data
election_data <- left_join(election_data, total_spending, by = c("ward", "precinct"))

#save to rds
saveRDS(election_data, "../temp/silverstein_dataset.rds")