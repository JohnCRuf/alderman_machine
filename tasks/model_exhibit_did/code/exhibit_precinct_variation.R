library(ggplot2)
library(tidyverse)
library(assertthat)
ARGS<- commandArgs(trailingOnly = TRUE)
agg_results_df <- read_csv(ARGS[1])

agg_results_df <- agg_results_df %>%
    mutate(Group = ifelse(grepl("top", filename), "top", "bottom"),
    precinct = as.numeric(str_extract(filename, "(?<=_)[0-9]+(?=_)")))

plot <- ggplot(agg_results_df, aes(x = precinct, y = att, ymin = lower_ci, ymax = upper_ci, color = Group, linetype = Group, shape = Group)) +
    geom_point(size = 3) +
    geom_line() +  # Add line to connect points
    geom_errorbar() +
    geom_hline(yintercept = 0, linetype = "dashed") +
    labs(x = "Precinct Count", y = "Average Treatment Effect on Treated (pp)") +
    theme_bw() +
    theme(legend.position = "bottom") +
    scale_color_manual(values = c("red","blue"), labels = c("Least supporting precincts", "Most supporting precincts")) +
    scale_shape_manual(values = c(19, 17), labels = c("Least supporting precincts", "Most supporting precincts")) +
    scale_linetype_manual(values = c("solid", "dashed"), labels = c("Least supporting precincts", "Most supporting precincts"))

ggsave(plot, filename = ARGS[2], width = 8, height = 6, units = "in", dpi = 300)