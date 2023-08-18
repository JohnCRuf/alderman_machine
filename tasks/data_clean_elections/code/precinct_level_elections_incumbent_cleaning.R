library(tidyverse)
library(stringr)
library(readr)
library(assertthat)
# Read and clean data
incumbent_df <- read.csv("../output/incumbent_voteshare_df_ward_level.csv") 
election_df <- read.csv("../input/elections.csv") %>%
  mutate(Candidate = gsub("  ", " ", Candidate),
         Candidate = gsub("Patricia ''Pat'' Dowell", "Pat Dowell", Candidate),
         Candidate = gsub("Thomas M. Tunney", "Tom Tunney", Candidate),
         Candidate = gsub("Rey Col????????N", "Rey Colon", Candidate))
#drop observations with JoAnn Thompson and year 2015 from elections
election_df <- election_df %>% filter(!(Candidate == "Joann Thompson" & year == 2015)) %>%
  rename(ward = Ward,
         precinct = Precinct,
         candidate = Candidate,
         votecount = Votecount)


#merge incumbent_df and election_df
precinct_level_elections <- left_join(election_df, incumbent_df, by = c("year", "ward", "type", "candidate"))
#write to csv
write_csv(precinct_level_elections, "../output/incumbent_challenger_voteshare_df_precinct_level.csv")