library(tidyverse)
library(sf)
library(stargazer)
ARGS<- commandArgs(trailingOnly = TRUE)
output_file <- paste0("../output/twfe_table_", ARGS[2],".tex")
#load in ARGS[1] as an RDA file
load(paste0(ARGS[1]))

treated_only_df <- treatment_df %>%
filter(treatment == 1) 
treated_wards <- treated_only_df$ward
#merge menu_df and treatment_df
did_df <- menu_df %>%
    mutate(ward = as.numeric(ward),
            precinct = as.numeric(precinct)) %>%
    left_join(treatment_df, by = c("ward")) %>%
    mutate(treatment_group = ifelse(ward %in% treated_wards, 1, 0),
            treatment = ifelse(ward %in% treated_wards & year > year_treat, 1, 0)) %>%
    group_by(ward, year) %>%
    mutate(total_spending = sum(weighted_cost)) %>%
    ungroup() %>%
    mutate(fraction_spending = weighted_cost / total_spending*100) 

#merge did_df and top_precincts, keep only matched ward-precincts
did_df <- did_df %>%
    right_join(top_precincts, by = c("ward", "precinct"))
#create treatment_2020, treatment_2021, treatment_2022
did_df <- did_df %>%
    mutate(treatment_2020 = ifelse(year == 2020 & treatment == 1, 1, 0),
            treatment_2021 = ifelse(year == 2021 & treatment == 1, 1, 0),
            treatment_2022 = ifelse(year == 2022 & treatment == 1, 1, 0))

DiD_all<-lm(fraction_spending~treatment_2020+treatment_2021+treatment_2022+factor(year)+factor(ward),data = did_df)
summary(DiD_all)
stargazer(DiD_all, omit = c("ward","year"))
#export stargazer table to output_file
capture.output(stargazer(DiD_all, omit = c("ward","year")), file = output_file)