library(ggplot2)
library(tidyverse)
library(assertthat)
ARGS<- commandArgs(trailingOnly = TRUE)
agg_results_df <- read_csv(ARGS[1])

agg_results_df <- agg_results_df %>%
    mutate(Group = ifelse(grepl("top", filename), "top", "bottom"),
    precinct = as.numeric(str_extract(filename, "(?<=_)[0-9]+(?=_)"))) %>%
    filter(precinct == 8)

agg_results_top <- agg_results_df %>%
    filter(Group == "top") %>%
    select(estimate, lower_ci, upper_ci, event_time) 

agg_results_bot <- agg_results_df %>%
    filter(Group == "bottom") %>%
    select(estimate, lower_ci, upper_ci,event_time)

plot_top <- ggplot(agg_results_top, aes(x = event_time, y = estimate, ymin = lower_ci, ymax = upper_ci)) +
    geom_point(size = 3) +
    geom_line() +  # Add line to connect points
    geom_errorbar() +
    geom_hline(yintercept = 0, linetype = "dashed") +
    labs(x = "Time", y = "Average Treatment Effect on Treated (pp)") +
    theme_bw()

ggsave(plot_top, filename = "../output/close_elections_8_top_over_time.png", width = 8, height = 6, units = "in", dpi = 300)

plot_bot <- ggplot(agg_results_bot, aes(x = event_time, y = estimate, ymin = lower_ci, ymax = upper_ci)) +
    geom_point(size = 3) +
    geom_line() +  # Add line to connect points
    geom_errorbar() +
    geom_hline(yintercept = 0, linetype = "dashed") +
    labs(x = "Time", y = "Average Treatment Effect on Treated (pp)") +
    theme_bw()

ggsave(plot_bot, filename = "../output/close_elections_8_bottom_over_time.png", width = 8, height = 6, units = "in", dpi = 300)