library(tidyverse)
library(ggplot2)
library(scales)
election_data <- read.csv("../input/incumbent_challenger_voteshare_df_precinct_level.csv") 
contribution_data <- read.csv("../input/stone_50_supporting_opposing_precincts_2003_2011.csv")

#take election data, filter for ward 50, year 2007, runoff
election_data <- election_data %>%
  filter(ward == 50, year == 2007, type == "Runoff")

election_data <- election_data %>%
  mutate(net = case_when(candidate == "Bernard L. Stone" ~ 1,
                         TRUE ~ -1))
#group by precinct and calculate net votes by taking votes when inc = 1 and minus votes when inc = 0
stone_data_inc <- election_data %>%
  group_by(precinct) %>%
  summarise(net_votes = sum(votecount*net)) %>%
  ungroup() %>%
    mutate(precinct = as.character(precinct))

#compute each precinct's percentile by net votes
stone_data_inc <- stone_data_inc %>%
  mutate(percentile_vote = ecdf(net_votes)(net_votes))

#take contribution data and compute each precinct's percentile by contribution
contribution_data <- contribution_data %>%
  mutate(percentile_cont = ecdf(total_contribution)(total_contribution)) %>%
  rename(precinct = precinct_locate) %>%
  mutate(precinct = as.character(precinct))

#join the two dataframes
stone_data_inc <- stone_data_inc %>%
  left_join(contribution_data, by = "precinct")

#create correlation of percentile vote and percentile contribution
correlation <- cor(stone_data_inc$percentile_vote, stone_data_inc$percentile_cont)
#export correlation rounded to 2 decimal places to .txt file
write.table(round(correlation, 2), "../output/stone_50_correlation.txt", row.names = FALSE, col.names = FALSE)