library(tidyverse)
library(sf)
library(did)
ARGS<- commandArgs(trailingOnly = TRUE)
#load in ARGS[1] as an RDA file
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
    mutate(treatment_group = ifelse(ward %in% treated_wards, year_treat+1, 0)) %>%
    group_by(ward, year) %>%
    mutate(total_spending = sum(weighted_cost)) %>%
    ungroup() %>%
    mutate(fraction_spending = weighted_cost / total_spending*100) 

#if args[2] contains "_top" then keep only top precincts
if (grepl("_top_", ARGS[2])) {
did_df_top <- did_df %>%
    right_join(top_precincts, by = c("ward", "precinct"))
} else if (grepl("_bottom_", ARGS[2])) {
did_df_bot <- did_df %>%
    right_join(bottom_precincts, by = c("ward", "precinct"))
}
#create numeric identifiers for each ward_precinct_locate
unique_numeric_ward_precinct_index <- did_df_bot %>%
    select(ward_precinct_locate) %>%
    distinct() %>%
    mutate(id = row_number())
did_df_bot <- did_df_bot %>%
    left_join(unique_numeric_ward_precinct_index, by = c("ward_precinct_locate")) %>%
    mutate(id = as.numeric(id))

unique_numeric_ward_precinct_index <- did_df_top %>%
    select(ward_precinct_locate) %>%
    distinct() %>%
    mutate(id = row_number())
did_df_top <- did_df_top %>%
    left_join(unique_numeric_ward_precinct_index, by = c("ward_precinct_locate")) %>%
    mutate(id = as.numeric(id))


#estimate model robust to heterogenous treatment effects
did_attgt_top<-att_gt(yname="fraction_spending",tname="year",idname="id", gname="treatment_group",clustervars = "ward", data=did_df_top)
did_agg.es<- aggte(did_attgt_top, type = "dynamic")
did_attgt_bot<-att_gt(yname="fraction_spending",tname="year",idname="id", gname="treatment_group",clustervars = "ward", data=did_df_bot)

png(ARGS[2], width = 800, height = 600)
ggdid(did_attgt)
dev.off()

