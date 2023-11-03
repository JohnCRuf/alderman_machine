library(tidyverse)
library(sf)
ARGS<- commandArgs(trailingOnly = TRUE)
n <- as.numeric(ARGS[1])
year_input <- as.numeric(ARGS[3])
output_file <- paste0("../temp/stone_eventstudy_", ARGS[1], "_precincts_", ARGS[3], "_year.rds")
election_data <- read.csv("../input/incumbent_challenger_voteshare_df_precinct_level.csv") 

menu_data <- readRDS("../input/ward_precinct_menu_panel_2003_2011.rds")

#drop observations of election data where year is greater than 2011 and ward != 50
election_data <- election_data %>%
  filter(ward == 50, year == year_input, type == "Runoff")

election_data <- election_data %>%
  mutate(net = case_when(inc == 0 ~ -1,
                         inc == 1 ~ 1))
#group by precinct and calculate net votes by taking votes when inc = 1 and minus votes when inc = 0
stone_data_inc <- election_data %>%
  group_by(precinct) %>%
  summarise(net_votes = sum(votecount*net)) %>%
  ungroup() %>%
    mutate(precinct = as.character(precinct))
median_netvotes <- median(stone_data_inc$net_votes)
#take the top and bottom ARGS[1] precincts by net votes
top_precinct_list <- stone_data_inc %>%
  arrange(desc(net_votes)) %>%
  head(n) %>%
  pull(precinct)

bottom_precinct_list <- stone_data_inc %>%
    arrange(net_votes) %>%
    head(n) %>%
    pull(precinct)

#create new df called "total_df" which is the sum of all precincts spending by year
total_df <- menu_data %>%
  filter(year >= 2005, year <= 2015, ward_locate == 50) %>%
  group_by(year) %>%
  summarise(total_spending = sum(weighted_cost)) %>%
  ungroup() 

menu_data <- menu_data %>%
  filter(year >= 2005, year <= 2015, ward_locate == 50) %>%
  rename(ward = ward_locate,
         precinct = precinct_locate) %>%
    mutate(precinct = as.character(precinct),
          lab = case_when(precinct %in% top_precinct_list ~ "Top",
                          precinct %in% bottom_precinct_list ~ "Bottom",
                          TRUE ~ "Other"
                          )) %>%
    filter(lab != "Other") %>%
    select(-geometry)

menu_data <- menu_data %>% 
  left_join(total_df, by = "year") %>% 
  mutate(observed_spending_fraction = weighted_cost/total_spending)
#TODO: how to assert that this is a perfect join?
#save to rds
saveRDS(menu_data, output_file)
