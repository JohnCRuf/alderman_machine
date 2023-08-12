library(tidyverse)
library(stringr)
library(readr)
library(assertthat)
# Read and clean data
elections <- read_csv("../input/elections.csv") %>%
  mutate(Candidate = gsub("  ", " ", Candidate),
         Candidate = gsub("Patricia ''Pat'' Dowell", "Pat Dowell", Candidate),
         Candidate = gsub("Thomas M. Tunney", "Tom Tunney", Candidate),
         Candidate = gsub("Rey Col????????N", "Rey Colon", Candidate))
#drop observations with JoAnn Thompson and year 2015 from elections
elections <- elections %>% filter(!(Candidate == "Joann Thompson" & year == 2015))

# Calculate total votes per candidate and winning candidates
election_group <- elections %>%
  group_by(year, Ward, type, Candidate) %>%
  summarize(total_votes_percandidate = sum(Votecount), .groups = "drop")

election_winners <- election_group %>%
  group_by(year, Ward, type) %>%
  mutate(votepct = total_votes_percandidate / sum(total_votes_percandidate),
         winner = ifelse(votepct > 0.5, 1, 0))

# Get lists of incumbents for each election year
year_vector_all <- sort(unique(elections$year), decreasing = TRUE)
#drop 2017 because that was a special election and 2003 because that is first year in data
year_vector <- year_vector_all[year_vector_all != 2017]
year_vector <- year_vector[year_vector != 2003]

appointments <- list(
  '2019' = c('Silvana Tabares'),
  '2015' = c('Deborah L. Mell', 'Natashia L. Holmes'),
  '2011' = c("Proco ''Joe'' Moreno", "Roberto Maldonado", "Deborah L. Graham", "Jason C. Ervin", "John A. Rice", "Timothy M. Cullerton"),
  '2007' = c("Darcel A. Beavers", "Lona Lane", "Thomas W. Murphy", "Thomas M. Tunney"),
  '2003' = c("Todd H. Stroger", "Latasha R. Thomas", "Emma M. Mitts"))

incumbents_list <- lapply(year_vector, function(year) {
  prev_year <- which(year_vector == year) + 1
  prev_winners <- election_winners %>% filter(year == year_vector[prev_year], winner == 1) %>% pull(Candidate)
  curr_candidates <- election_winners %>% filter(year == year) %>% pull(Candidate)
  c(intersect(prev_winners, curr_candidates), appointments[[as.character(year)]])
})

names(incumbents_list) <- year_vector
#manually inserting incumbent lists for 2003 and 2017 due to first year in data and special election
incumbents_list <- append(incumbents_list, list('2017' = c("Sophia King")), after = 1)
incumbents_list <- append(incumbents_list, list('2003' = c(
c("Todd H. Stroger", "Latasha R. Thomas", "Emma M. Mitts", "Rafael ''Ray'' Frias", 
"Dorothy J. Tillman", "Toni Preckwinkle", "Leslie A. Hairston", "Freddrenna M. Lyle",
 "William M. Beavers", "Anthony A. Beale", "John A. Pope", "James A. Balcer", 
 "Frank J. Olivo",  "Theodore ''Ted'' Thomas", "Shirley A. Coleman", "Virginia A. Rugai", 
 "Arenda Troutman", "Leonard Deville", "Ricardo Munoz", "Michael R. Zalewski", "Michael D. Chandler", 
 "Daniel ''Danny'' Solis", "Billy Ocasio", "Walter Burnett, Jr.", "Ed H. Smith", 
 "Isaac ''Ike'' Sims Carothers", "Regner ''Ray'' Suarez", "Ted Matlak", "Richard F. Mell", 
 "Carrie M. Austin", "Vilma Colom", "William J.p. Banks", "Thomas R. Allen", 
 "Margaret Laurino", "Patrick J. O'connor", "Brian G. Doherty", "Burton F. Natarus", 
 "Vi Daley", "Helen Shiller", "Gene Schulter", "Joe Moore", "Bernard L. Stone", "Jesse D. Granato",
"Edward M. Burke"))))
incumbents_all <- unique(unlist(incumbents_list))

# Initialize incumbent columns
incumbent_cols <- paste0("inc_", year_vector_all)
incumbent_vs <- election_winners %>%
  select(-winner) %>%
  bind_cols(as_tibble(matrix(0, nrow=nrow(election_winners), ncol=length(year_vector_all), dimnames = list(NULL, incumbent_cols))))

# Add incumbent information to dataset
incumbent_vs <- incumbent_vs %>%
  mutate(across(all_of(incumbent_cols), ~ifelse(Candidate %in% incumbents_list[[match(cur_column(), incumbent_cols)]], 1, 0)))

incumbent_vs_df <- incumbent_vs%>%
  mutate(inc = case_when(
    inc_2019 == 1 & year == 2019 ~ 1,
    inc_2017 == 1 & year == 2017 ~ 1,
    inc_2015 == 1 & year == 2015 ~ 1,
    inc_2011 == 1 & year == 2011 ~ 1,
    inc_2007 == 1 & year == 2007 ~ 1,
    inc_2003 == 1 & year == 2003 ~ 1,
    TRUE ~ 0
  )) %>%
  select(-starts_with("inc_")) %>%
  distinct()

#assert that all ward-year combinations have only one incumbent
assert_that(all(incumbent_vs_df %>%
  filter(inc==1 & type=="General") %>%
  group_by(year, Ward) %>%
  summarize(n = n()) %>%
  pull(n) < 2), msg = "ERROR: SOME ELECTIONS HAVE 2 INCUMBENTS")

#replace variable Ward with "ward"
incumbent_vs_df <- incumbent_vs_df %>%
  rename(ward = Ward)  %>%
  rename(candidate = Candidate)

write_csv(incumbent_vs_df, file = "../output/incumbent_voteshare_df_ward_level.csv")


#aggregate_candidate_df <- election_winners %>%
 # left_join(incumbent_vs, by = c("Candidate", "year", "Ward", "type", "votepct")) %>%
#  mutate(across(starts_with("inc_"), ~ifelse(is.na(.x), 0, .x)))

#write_csv(aggregate_candidate_df, file = "../output/aggregate_candidate_df.csv")
#saveRDS(incumbents_list, file = "../output/incumbents_list.RDS")