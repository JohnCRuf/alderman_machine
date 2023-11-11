library(tidyverse)
library(sf)
ARGS<- commandArgs(trailingOnly = TRUE)
#apply arguments
input_filename <- ARGS[1]
ward <- ARGS[2]
output_filename <- ARGS[3]
# load panel data
df <- readRDS(input_filename)
#filter to ward_locate = ward
df <- df %>%
  filter(ward_locate == ward) %>%
  filter(year >= 2012, year <= 2022)
#group by precinct_locate and compute sum of total_contributions
df <- df %>%
  group_by(precinct_locate) %>%
  summarise(total_contribution = sum(total_contribution)) %>%
  ungroup()
#create an ordinal rank of precincts by total_contributions
df <- df %>%
  mutate(rank = rank(total_contribution, ties.method = "first"))
df <- df %>%
  arrange(rank)
#add a variable called ward that is the same as the input argument
df <- df %>%
  mutate(ward = ward,
         map = "2012-2022")
#save as csv
write_csv(df, output_filename)

