library(tidyverse)
library(sf)
ARGS<- commandArgs(trailingOnly = TRUE)
n <- as.numeric(ARGS[1])
output_file <- paste0("../temp/stone_eventstudy_", ARGS[1], "_precincts.rds")
election_data <- read.csv("../input/incumbent_challenger_voteshare_df_precinct_level.csv") 

menu_data <- readRDS("../input/ward_precinct_menu_panel_2003_2011.rds")

#drop observations of election data where year is greater than 2011 and ward != 50
election_data <- election_data %>%
  filter(ward == 50, year == 2007, type == "Runoff")

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
#make new df middle_precincts with new variable median_vote_dist which is the absolute value of the difference between net votes and median net votes
middle_precinct_list <- stone_data_inc %>%
  mutate(median_vote_dist = abs(net_votes - median_netvotes)) %>%
  arrange(median_vote_dist) %>%
  head(n) %>%
  pull(precinct)


menu_data <- menu_data %>%
  filter(year >= 2005, year <= 2015, ward_locate == 50) %>%
  rename(ward = ward_locate,
         precinct = precinct_locate) %>%
    mutate(precinct = as.character(precinct),
          lab = case_when(precinct %in% top_precinct_list ~ "Top",
                          precinct %in% bottom_precinct_list ~ "Bottom",
                          precinct %in% middle_precinct_list ~ "Middle",
                          TRUE ~ "Other"
                          )) %>%
    filter(lab != "Other") %>%
    select(-geometry)
#create new dataframe with total spending across all precincts
total_spending <- menu_data %>%
  group_by(year, ward) %>%
  summarise(total_spending = sum(weighted_cost)) %>%
  ungroup() %>%
  mutate(total_spending = total_spending/1000)
#save as csv
csv_label <- paste0("../output/stone_eventstudy_", ARGS[1], "_precincts.csv")
write_csv(total_spending, csv_label)


#save to rds
saveRDS(menu_data, output_file)