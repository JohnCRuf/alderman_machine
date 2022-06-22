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
library("rstudioapi")
setwd(dirname(getActiveDocumentContext()$path)) 
RDD_df<-read_csv("../input/RDD_df.csv") %>%
  mutate(IW=ifelse(votepct>0.5,1,0),
         IVP=(votepct-0.5)*100,
         OffMenu=off_menu)
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

#Density Test
myDCdensity <- function(runvar, cutpoint, my_abline = 0, my_x_axis="Incumbent Vote Percent (%)",
                        my_y_axis="Density"){
  
  # get the default plot
  myplot <- DCdensity(runvar, cutpoint)
  
  # 'additional graphical options to modify the plot'
  abline(v = my_abline)
  title(xlab=my_x_axis,ylab=my_y_axis)

  
  # return
  return(myplot)
}

myDCdensity(RDD_df$IVP,0)


#Placebo Test
IVS_RDD<-function(df){
  output<-lm(OffMenu~IW+IVP+IW*IVP,data=df)
}
bandwidth_implement<-function(df,band_l,band_u){
  df %>%
    filter(IVP>band_l, IVP<band_u)
}


cutpoints=5:25
placebo=rep(0,length(cutpoints))
placebo_pvalue=rep(0,length(cutpoints))
for(i in 1:length(cutpoints)){
  cp=cutpoints[i]
  df<-RDD_df %>%
    filter(IVP>0) %>%
    mutate(IW=ifelse(IVP>cp,1,0))
  IK<-IKbandwidth(df$IVP,df$OffMenu,cutpoint=cp, verbose=FALSE)
  IK_df<-bandwidth_implement(df,-IK+cp,IK+cp)
  IK_model<-IVS_RDD(IK_df)
  placebo[i]=IK_model$coefficients[2]
  placebo_pvalue[i]=summary(IK_model)$coefficients[2,4]
}

placebo_df<-tibble(cutpoints,placebo,placebo_pvalue)
placebo_df %>%
  ggplot(aes(x=cutpoints, y=placebo))+
  geom_point()+
  xlab("Positive Cutpoint (%)")+
  ylab("Estimated Effect ($)")+
  scale_y_continuous(labels = human_usd)

placebo_df %>%
  ggplot(aes(x=cutpoints, y=placebo_pvalue))+
  geom_point()+
  xlab("Positive Cutpoint (%)")+
  ylab("P-Value of Estimated Effect")
