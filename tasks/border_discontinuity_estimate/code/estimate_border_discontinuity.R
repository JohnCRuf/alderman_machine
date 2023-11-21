library(lmtest)
library(tidyverse)
library(sandwich)
library(ggplot2)

#load 
df <- read.csv("../input/border_discontinuity_data.csv")

df <- df %>%
  mutate(needs_gap = pct_of_needs_home - pct_of_needs_nearest) %>%
  filter(abs(needs_gap) > 10)  %>%
  mutate(distance = distance_to_ward / 1000) %>%
  mutate(distance = ifelse(needs_gap>0, distance, -distance)) %>%
  mutate(menu_spending = weighted_cost/total_wardlocate_spending * 100) %>%
  mutate(disc = ifelse(needs_gap > 0, 1, 0)) %>%
  filter(abs(distance) < 1) 
#create a variable that is a vector of ward_locate and nearest_ward called border_vector
df$border_name <- apply(df[, c("ward_locate", "nearest_ward")], 1, function(x) {
  sorted_x <- sort(x)
  paste("Border", sorted_x[1], "-", sorted_x[2])
})

#run regression
reg <- lm(menu_spending ~ disc + abs(distance) + abs(distance)*disc + factor(border_name)*factor(cycle), data = df)
#display coeftest without anything that starts with factor
summary(reg)
test <- coeftest(reg, vcov = vcovCL, cluster = df$ward_locate)[!grepl("factor", rownames(coeftest(reg, vcov = vcovCL, cluster = df$border_name))),]

#run quadratic regression
reg2 <- lm(menu_spending ~ disc + distance + distance*disc + I(distance^2) + I(distance^2)*disc + factor(border_name)*factor(cycle), data = df)

test2 <- coeftest(reg2, vcov = vcovCL, cluster = df$ward_locate)[!grepl("factor", rownames(coeftest(reg2, vcov = vcovCL, cluster = df$border_name))),]

#combine test and test2 into one latex table
library(knitr)
kable(test, digits = 3, format = "latex", booktabs = TRUE, caption = "Border discontinuity estimates")
#export to .tex
writeLines(c("\\begin{table}[htb]", "\\centering", "\\caption{Border discontinuity estimates}", "\\label{tab:reg}", "\\begin{tabular}{lrrrr}"), "../output/border_discontinuity_estimate.tex")
# #run regression with just border fixed effects
# border_resid <- lm(menu_spending ~ factor(border_name)*factor(cycle), data = df)
# #add residuals to df
# df$border_resid <- resid(border_resid)
# # so create a set of 10 distance bines that are evenly spaced and 0 is the middle. Each bin should be 0.2km wide
# df$distance_bin <- cut(df$distance, breaks = seq(-1, 1, 0.2), include.lowest = TRUE)
# #group by distance bin and calculate mean and standard deviation of menu_spending
# df_plot <- df %>%
#   group_by(distance_bin) %>%
#   summarise(mean = mean(border_resid), sd = sd(menu_spending), n = n()) %>%
#   mutate(se = sd / sqrt(n))
# # create a plot of the mean for each bin with standard error bars
# ggplot(df_plot, aes(x = distance_bin, y = mean)) +
#   geom_errorbar(aes(ymin = mean - se, ymax = mean + se), width = 0.1) +
#   geom_point() +
#   geom_line() +
#   theme_bw() +
#   labs(x = "Distance from ward boundary (km)", y = "Mean menu spending (%)")