library(tidyverse)
library(ggplot2)
library(scales)
library(sf)
ARGS<- commandArgs(trailingOnly = TRUE)
n_precincts <- as.numeric(ARGS[1])
menu_data <- readRDS("../input/ward_precinct_menu_panel_2003_2011.rds")
stone_contribution_df <- read.csv("../input/stone_50_supporting_opposing_precincts_2003_2011.csv")
output_file <- paste0("../output//ward_50_contribution_", toString(ARGS[1]), "_precincts_timeline.png")
#group by year and calculate the mean of the top and bottom precincts average per-precinct spending

#remove geographic information from menu_data
menu_data <- menu_data %>%
  select(-geometry)
#create column called observed_spending that is the sum of weighted_cost for each year
df <- menu_data %>%
  filter(year >= 2005, year <= 2015, ward_locate == 50) %>%
  group_by(year) %>%
  summarise(observed_spending = sum(weighted_cost),
            precinct = precinct_locate,
            weighted_cost = weighted_cost) %>%
  ungroup()

# create a list of the largest ranked precinct_locate values in stone_contribution_df
top_precinct_list <- stone_contribution_df %>%
  arrange(desc(total_contribution)) %>%
  head(n_precincts) %>%
  pull(precinct_locate)

bot_precinct_list <- stone_contribution_df %>%
  arrange(total_contribution) %>%
  head(n_precincts) %>%
  pull(precinct_locate)
# label precinct_locate in df as "Top" if it is in top_precinct_list, "Bottom" if it is in bot_precinct_list, and "Other" otherwise
df <- df %>%
  mutate(lab = case_when(precinct %in% top_precinct_list ~ "Most Contributing Precincts",
                         precinct %in% bot_precinct_list ~ "Least Contributing Precincts",
                         TRUE ~ "Intermediate Precincts"
                         ))

df <- df %>%
  group_by(year, lab) %>%
  summarise(count = n(),
            observed_spending_fraction = sum(weighted_cost)/observed_spending/n()*100,
            total_spending = sum(weighted_cost)) %>%
  ungroup()

#create a line chart of the mean spending of the top and bottom precincts
figure <- ggplot(df, aes(x = as.factor(year))) + 
  geom_line(aes(y = observed_spending_fraction, color = lab, linetype = lab, group = lab)) + 
  geom_vline(aes(xintercept = "2011"), linetype="dashed", color = "grey50") + 
  labs(x = "Year", y = "Fraction of spending per precinct (%)") +  
  scale_y_continuous(labels = comma_format(scale = 1)) +  
  scale_x_discrete(breaks = unique(df$year)[seq(1, length(unique(df$year)), by = 2)]) +
  scale_color_discrete(name="Group") +   # Rename the color legend
  scale_linetype_discrete(name="Group") + # Rename the linetype legend
  theme_bw() +
  theme(
    plot.caption = element_text(hjust = 0.5, size = 12, margin = margin(t = 0, b = 0)),
    plot.margin = margin(0, 0, 0, 0)  # top, right, bottom, left margins set to zero
  )
#save the figure as a png
png(filename = output_file, width = 6, height = 4, units = "in", res = 300)
print(figure)
dev.off()
