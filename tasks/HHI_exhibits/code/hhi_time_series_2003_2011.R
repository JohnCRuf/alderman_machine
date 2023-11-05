library(tidyverse)
library(assertthat)
library(ggplot2)
#read in csv file
hhi_df <- read_csv("../input/menu_annual_hhi_2003_2011.csv")
#filter year to be within 2005 and 2011
hhi_df <- hhi_df %>%
  filter(year >= 2005, year <= 2011)
hhi_df <- hhi_df %>%
  group_by(year) %>%
  summarise(hhi = mean(hhi)) %>%
  ungroup()
# create a time series plot of the mean hhi by year with a line at 2007
figure <- ggplot(hhi_df, aes(x = year, y = hhi)) +
  geom_line() +
  geom_vline(xintercept = 2007, linetype = "dashed") +
  labs(title = "Mean HHI by Year",
       x = "Year",
       y = "Mean HHI") +
  theme(plot.title = element_text(hjust = 0.5))
#save figure to a png file without using ggsave
ggsave("../output/HHI_annual_cycle_2005_2011.png", width = 6, height = 4, units = "in", dpi = 300)
