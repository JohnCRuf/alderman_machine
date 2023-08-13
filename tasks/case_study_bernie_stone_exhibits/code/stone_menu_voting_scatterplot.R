library(sf)
library(tidyverse)
library(assertthat)
library(ggmap)
library(ggplot2)
library(viridis)
library(labeling)

ARGS<- commandArgs(trailingOnly = TRUE)
output_file <- paste0("../output/stone_", ARGS[1], "_", ARGS[2], "_precinct_results.png")
#load the data
stone_data <- readRDS("../temp/stone_dataset.rds")

#filter stone data to include only data with year = ARGS[1] and type = ARGS[2]
stone_data <- stone_data %>%
  filter(year == 2007, type == "runoff")
#add variable net which is -1 if inc 0 and 1 if inc = 1
stone_data <- stone_data %>%
  mutate(net = case_when(inc == 0 ~ -1,
                         inc == 1 ~ 1))
#group by precinct and calculate net votes by taking votes when inc = 1 and minus votes when inc = 0
stone_data_inc <- stone_data %>%
  group_by(precinct, geometry) %>%
  summarise(net_votes = sum(votecount*net),
            total_spending = sum(total_spending*inc)) %>%
  ungroup() 

#create a density chart of net votes vs total spending

figure <- ggplot(stone_data_inc, aes(x = net_votes, y = total_spending)) +
  geom_point() +
  labs(x = "Net votes for Ald. Stone", y = "Total spending by Ald. Stone (in $K)") +  # Adjusted y-label
  scale_y_continuous(labels = comma_format(scale = 1/1000)) +  # Adjust y-axis labels to show in thousands
  theme_bw() +
  theme(
    plot.caption = element_text(hjust = 0.5, size = 12, margin = margin(t = 0, b = 0)),
    plot.margin = margin(0, 0, 0, 0),  # top, right, bottom, left margins set to zero
    legend.title = element_text(hjust = 0.5)  # horizontally center the legend title
  )
