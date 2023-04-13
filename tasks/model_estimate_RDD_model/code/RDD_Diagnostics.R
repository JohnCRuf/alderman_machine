#John Ruf 05/22
#This code is meant to implement a variety of RDD diagnostics to determine
#if the RDD is trustworthy.
library(tidyverse)
library(stringr)
library(ggplot2)
library(rdrobust)
library(stargazer)
library(rdd)
library(XML)
source("RDD_functions.R")
RDD_df<-read_csv("../temp/RDD_df.csv") %>%
  mutate(IW=ifelse(votepct>0.5,1,0),
         IVP=(votepct-0.5)*100,
         OffMenu=off_menu)
myDCdensity(RDD_df$IVP, 0, "../output/rdd_density.png")

#Placebo Test
cutpoints = 5:25
placebo = rep(0, length(cutpoints))
placebo_pvalue = rep(0, length(cutpoints))
for(i in 1:length(cutpoints)){
  cp = cutpoints[i]
  df <- RDD_df %>%
    filter(IVP > 0) %>%
    mutate(IW = ifelse(IVP > cp, 1, 0))
  IK <- IKbandwidth(df$IVP, df$OffMenu, cutpoint = cp, verbose = FALSE)
  IK_df <- bandwidth_implement(df, - IK + cp , IK+cp)
  IK_model <- IVS_RDD(IK_df)
  placebo[i] <- IK_model$coefficients[2]
  placebo_pvalue[i] <- summary(IK_model)$coefficients[2, 4]
}

placebo_df <- tibble(cutpoints, placebo, placebo_pvalue)
placebo_plot_effectsize <- placebo_df %>%
  ggplot(aes(x = cutpoints, y = placebo)) +
  geom_point() +
  xlab("Positive Cutpoint (%)") +
  ylab("Estimated Effect ($)") +
  scale_y_continuous(labels = human_usd)
ggsave("../output/placebo_test_effects.png", placebo_plot_effectsize)

placebo_plot_pvalue <- placebo_df %>%
  ggplot(aes(x = cutpoints, y = placebo_pvalue)) +
  geom_point() +
  xlab("Positive Cutpoint (%)") +
  ylab("P-Value of Estimated Effect")
ggsave("../output/placebo_test_pvalue.png", placebo_plot_pvalue)