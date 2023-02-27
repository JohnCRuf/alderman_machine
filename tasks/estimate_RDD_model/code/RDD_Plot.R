
library(tidyverse)
library(stringr)
library(ggplot2)
library(stargazer)
library(XML)
source("RDD_functions.R")
RDD_df<-read_csv("../temp/RDD_df.csv") %>%
  mutate(inc_win=ifelse(votepct>0.5,1,0)) %>%
  filter(votepct!=1)

RDD_visualization <- RDD_df %>%
ggplot(aes(x = (votepct-0.5) * 100, y = off_menu, color = factor(inc_win))) +
  geom_point() +
  geom_smooth(method = "lm", formula = y ~ poly(x, 1, raw=TRUE), se = F) +
  scale_y_continuous(labels = human_usd) +
  xlab("Incumbent Vote Lead (%)") +
  ylab("Ward Off-Menu Spending After Election ($)") +
  labs(color="Incumbent Win")
ggsave("../output/RDD_plot.png", RDD_visualization)

rdd_stats<-RDD_df %>%
  transmute(off_menu,
            votepct = votepct * 100)
writeLines(capture.output(stargazer(as.data.frame(rdd_stats),
label = "rddstats",
title = "Summary Statistics for the Regression Discontinuity Analysis")),
  "../output/RDD_statistics.tex")

hist_menu <- rdd_stats %>%
  ggplot(aes(x = off_menu)) +
  geom_histogram() +
  xlab("Off-Menu Expenditures") +
  ylab("Number of Observations") +
  scale_x_continuous(labels = human_usd)
ggsave("../output/off_menu_expenditures_histogram.png", hist_menu)
hist_vote<-rdd_stats %>%
  ggplot(aes(x=votepct)) +
  geom_histogram() +
  xlab("Incumbent Vote Share (%)") +
  ylab("Number of Observations")
ggsave("../output/voteshare_histogram.png", hist_vote)