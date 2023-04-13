library(tidyverse)
library(stringr)
library(stargazer)
library(XML)
library("rstudioapi")


setwd(dirname(getActiveDocumentContext()$path)) 
menu_df<-read_csv("../input/menu_panel_df.csv")
treated_wards=c(2,7,11,15,17,18,24,29,31,35,36,41)
electorally_treated=c(7,10,15,18,29,31,35,36,41)
retirement_treated=c(2,11,17,24,38)

DiD_all_df<-menu_df %>%
  mutate(treated_2015=ifelse(ward %in% treated_wards,"treated","untreated"))

did_summary<-DiD_all_df %>% 
  transmute(treated_2015,off_menu) %>%
  group_by(treated_2015)%>%
  summarize(N=n(),
            Mean=mean(off_menu),
            std=sd(off_menu),
            min=min(off_menu),
            max=max(off_menu))

stargazer(did_summary, summary = FALSE, digits = 2)
#Numbers Formatting: https://github.com/fdryan/R/blob/master/ggplot2_formatter.r
human_numbers <- function(x = NULL, smbl ="", signif = 1){
  humanity <- function(y){
    
    if (!is.na(y)){
      tn <- round(abs(y) / 1e12, signif)
      b <- round(abs(y) / 1e9, signif)
      m <- round(abs(y) / 1e6, signif)
      k <- round(abs(y) / 1e3, signif)
      
      if ( y >= 0 ){
        y_is_positive <- ""
      } else {
        y_is_positive <- "-"
      }
      
      if ( k < 1 ) {
        paste0( y_is_positive, smbl, round(abs(y), signif ))
      } else if ( m < 1){
        paste0 (y_is_positive, smbl,  k , "k")
      } else if (b < 1){
        paste0 (y_is_positive, smbl, m ,"m")
      }else if(tn < 1){
        paste0 (y_is_positive, smbl, b ,"bn")
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


hist<-DiD_all_df %>%
  ggplot(aes(x=off_menu)) +
  geom_histogram()+
  xlab("Off-Menu Expenditures")+
  ylab("Number of Unit-Year Observations")+
  scale_x_continuous(labels = human_usd)
