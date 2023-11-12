library(tidyverse)
library(sf)
library(stargazer)
library(sandwich)
library(lmtest)
ARGS<- commandArgs(trailingOnly = TRUE)
load(paste0(ARGS[1]))

treated_only_df <- treatment_df %>%
filter(treatment == 1) 
treated_wards <- treated_only_df$ward
election_year <- unique(treated_only_df$year_treat)
#merge menu_df and treatment_df
did_df <- menu_df %>%
    mutate(ward = as.numeric(ward),
            precinct = as.numeric(precinct)) %>%
    left_join(treatment_df, by = c("ward")) %>%
    mutate(treatment_group = ifelse(ward %in% treated_wards, 1, 0)) %>%
    group_by(ward, year) %>%
    mutate(total_spending = sum(weighted_cost)) %>%
    ungroup() %>%
    mutate(fraction_spending = weighted_cost / total_spending*100) 

#if args[2] contains "_top" then keep only top precincts
if (grepl("_top_", ARGS[2])) {
did_df <- did_df %>%
    right_join(top_precincts, by = c("ward", "precinct"))
} else if (grepl("_bottom_", ARGS[2])) {
did_df <- did_df %>%
    right_join(bottom_precincts, by = c("ward", "precinct"))
}
#create treatment_2020, treatment_2021, treatment_2022
did_df <- did_df %>%
    mutate(treatment_0 = ifelse(year == election_year+1 & treatment_group == 1, 1, 0),
            treatment_1 = ifelse(year == election_year+2 & treatment_group == 1, 1, 0),
            treatment_2 = ifelse(year == election_year+3 & treatment_group == 1, 1, 0))

twfe_did<-lm(fraction_spending~factor(year)+factor(ward_precinct_locate)+treatment_0+treatment_1+treatment_2,data = did_df)
did_cl <- coeftest(twfe_did, vcov = vcovCL, cluster = ~ward)
#export stargazer table to output_file
capture.output(stargazer(did_cl,  omit = c("ward","year")), file = ARGS[2])

#extra code to double check clusters matter
# capture.output(stargazer(twfe_did,  omit = c("ward","year")), file = "test.tex")