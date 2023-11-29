library(tidyverse)
library(sf)
library(did)
ARGS<- commandArgs(trailingOnly = TRUE)
#load in ARGS[1] as an RDA file
load(paste0(ARGS[1]))
#grab the filename from ARGS[1]
input_filename <- ARGS[1]
input_filename_stub <- basename(input_filename)
#remove the .rda from the filename
input_filename_stub <- str_remove(input_filename_stub, ".rda")
#determine if top or bottom using ARGS[2]

#create output filenames
output_figure_filename <- paste0("../output/", input_filename_stub, "_", ARGS[2], "_figure", ".png")
output_estimate_agg_filename <- paste0("../output/", input_filename_stub, "_", ARGS[2], "_estimate_agg", ".txt")
output_estimate_filename <- paste0("../output/", input_filename_stub,"_", ARGS[2], "_estimate", ".txt")

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
if (grepl("top", ARGS[2])) {
did_df <- did_df %>%
    right_join(top_precincts, by = c("ward", "precinct"))
} else if (grepl("bottom", ARGS[2])) {
did_df <- did_df %>%
    right_join(bottom_precincts, by = c("ward", "precinct"))
}
#create numeric identifiers for each ward_precinct_locate
unique_numeric_ward_precinct_index <- did_df %>%
    select(ward_precinct_locate) %>%
    distinct() %>%
    mutate(id = row_number())
did_df <- did_df %>%
    left_join(unique_numeric_ward_precinct_index, by = c("ward_precinct_locate")) %>%
    mutate(id = as.numeric(id))


#estimate model robust to heterogenous treatment effects
did_attgt<-att_gt(yname="fraction_spending",tname="year",idname="id", gname="treatment_group",clustervars = "ward", data=did_df)
did_agg.es<- aggte(did_attgt, type = "dynamic")

png(output_figure_filename, width = 800, height = 600)
ggdid(did_agg.es, xlim =c(-4,4))
dev.off()

#export the summary of did_attgt to a text file 
sink(output_estimate_filename)
summary(did_attgt)
sink()

#export the summary of did_agg.es to a text file
sink(output_estimate_agg_filename)
summary(did_agg.es)
sink()