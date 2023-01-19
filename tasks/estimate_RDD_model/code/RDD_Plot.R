
library(tidyverse)
library(stringr)
library(ggplot2)
library(stargazer)
library(XML)
RDD_df<-read_csv("../temp/RDD_df.csv") %>%
  mutate(inc_win=ifelse(votepct>0.5,1,0)) %>%
  filter(votepct!=1)

human_numbers <- function(x = NULL, smbl ="", signif = 1) {
  humanity <- function(y) {
    if (!is.na(y)){
      tn <- round(abs(y) / 1e12, signif)
      b <- round(abs(y) / 1e9, signif)
      m <- round(abs(y) / 1e6, signif)
      k <- round(abs(y) / 1e3, signif)
      if (y >= 0) {
        y_is_positive <- ""
      } else {
        y_is_positive <- "-"
      }
      if ( k < 1 ) {
        paste0( y_is_positive, smbl, round(abs(y), signif))
      } else if ( m < 1) {
        paste0 (y_is_positive, smbl,  k, "k")
      } else if (b < 1) {
        paste0 (y_is_positive, smbl, m, "m")
      }else if(tn < 1) {
        paste0 (y_is_positive, smbl, b, "bn")
      } else {
        paste0 (y_is_positive, smbl,  comma(tn), "tn")
      }
    } else if (is.na(y) | is.null(y)){
      "-"
    }
  }
  sapply(x,humanity)
}

human_usd   <- function(x){human_numbers(x, smbl = "$")}


RDD_visualization <- RDD_df %>%
ggplot(aes(x = (votepct-0.5) * 100, y = off_menu, color = factor(inc_win))) +
  geom_point() +
  geom_smooth(method = "lm", formula = y ~ poly(x, 1, raw=TRUE), se = F) +
  scale_y_continuous(labels = human_usd) +
  xlab("Incumbent Vote Lead (%)") +
  ylab("Ward Off-Menu Spending After Election ($)") +
  labs(color="Incumbent Win")
ggsave(../output/RDD_plot.png, RDD_visualization)

rdd_stats<-RDD_df %>%
  transmute(off_menu,
            votepct = votepct * 100)
writeLines(capture.output(stargazer(as.data.frame(rdd_stats))),
  "../output/RDD_statistics.tex")

hist_menu <- rdd_stats %>%
  ggplot(aes(x = off_menu)) +
  geom_histogram() +
  xlab("Off-Menu Expenditures") +
  ylab("Number of Observations") +
  scale_x_continuous(labels = human_usd)
ggsave(../output/off_menu_expenditures_histogram.png, hist_menu)
hist_vote<-rdd_stats %>%
  ggplot(aes(x=votepct)) +
  geom_histogram() +
  xlab("Incumbent Vote Share (%)") +
  ylab("Number of Observations")
ggsave(../output/voteshare_histogram.png, hist_vote)