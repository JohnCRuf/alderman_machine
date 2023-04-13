#John Ruf 05/2022
#This code is intended to develop a plot describing the DiD estimator

library(tidyverse)
library(stringr)
library(ggplot2)
library(XML)
library("rstudioapi")


setwd(dirname(getActiveDocumentContext()$path)) 
menu_df<-read_csv("../input/menu_panel_df.csv")
treated_wards=c(2,7,11,15,17,18,24,29,31,35,36,41)
retire_2015=c(2,11,17,24,38)
retire_2019=c(20,22,25,39,47)

DiD_df<-menu_df %>%
  mutate(treated=ifelse(ward %in% treated_wards,1,0))

retire_df<- menu_df %>%
  mutate(retire_2015=ifelse(ward %in% retire_2015,1,0),
         retire_2019=ifelse(ward %in% retire_2019,1,0)) %>%
  group_by(retire_2015,retire_2019,year) %>%
  summarize(off_menu_retire_gr=mean(off_menu)) %>%
  mutate(retirement=case_when(retire_2015==1~2015,
                              retire_2019==1~2019,
                              TRUE~0))

Grouped_df<- DiD_df %>%
  group_by(treated,year) %>%
  summarize(off_menu_gr=sum(off_menu)/n())



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

stargazer(did_summary, summary = FALSE, digits = 2)


Grouped_df %>%
  ggplot(aes(x=year,y=off_menu_gr, color=factor(treated)))+
  geom_point()+
  geom_line()+
  geom_vline(xintercept=2016, linetype="dashed", size=0.5)+
  xlab("Year")+
  ylab("Average Off-Menu Expenditures")+
  labs(color="Treatment")+
  scale_y_continuous(labels = human_usd)


retire_df %>%
  ggplot(aes(x=year,y=off_menu_retire_gr, color=factor(retirement)))+
  geom_point()+
  geom_line()+
  xlab("Year")+
  ylab("Average Off-Menu Expenditures")+
  labs(color="Treatment")+
  scale_y_continuous(labels = human_usd)
