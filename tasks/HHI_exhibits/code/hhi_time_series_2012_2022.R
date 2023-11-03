library(tidyverse)
library(assertthat)
library(ggplot2)
#read in csv file
hhi_df <- read_csv("../input/menu_annual_hhi_2012_2022.csv")
#filter year to be within 2005 and 2011
hhi_df <- hhi_df %>%
  filter(year >= 2012, year <= 2022)
#collapse to mean hhi by year
hhi_df <- hhi_df %>%
  group_by(year) %>%
  summarise(hhi = mean(hhi)) %>%
  ungroup()
# create a time series plot of the mean hhi by year with a line at 2007
ggplot(hhi_df, aes(x = year, y = hhi)) +
  geom_line() +
  geom_vline(xintercept = 2015, linetype = "dashed") +
  geom_vline(xintercept = 2019, linetype = "dashed") +
  labs(title = "Mean HHI by Year",
       x = "Year",
       y = "Mean HHI") +
  theme(plot.title = element_text(hjust = 0.5))
#save plot to png
ggsave("../output/HHI_annual_cycle_2012_2022.png", width = 6, height = 4, units = "in", dpi = 300)