#John Ruf 5/2020
#This code implements the RDD models 
library(tidyverse)
library(stringr)
library(ggplot2)
library(rdrobust)
library(stargazer)
library(rdd)
library(XML)
library("rstudioapi")
setwd(dirname(getActiveDocumentContext()$path)) 
RDD_df<-read_csv("../input/RDD_df_beauty.csv") %>%
  mutate(IW=ifelse(votepct>0.5,1,0),
         IVS=votepct-0.5,
         beauty=beauty)

#Defining functions useful for implementing lots of models

IVS_RDD<-function(df){
  output<-lm(beauty~IW+IVS+IW*IVS,data=df)
}
bandwidth_implement<-function(df,band_l,band_u){
  df %>%
    filter(IVS>band_l, IVS<band_u)
}

#Model 1: Full Model
full_model<-IVS_RDD(RDD_df)

#Model 2: IK Bandwidth
IK<-IKbandwidth(RDD_df$IVS,RDD_df$beauty,cutpoint=0, verbose=FALSE)
IK_df<-bandwidth_implement(RDD_df,-IK,IK)
IK_model<-IVS_RDD(IK_df)
summary(IK_model)

#Model 3: CCT_MSE Optimal Bandwidth

MSE<-rdbwselect(x=RDD_df$IVS,y=RDD_df$beauty,bwselect = "msetwo")
MSE_df<-bandwidth_implement(RDD_df,-MSE$bws[1],MSE$bws[2])
MSE_model<-IVS_RDD(MSE_df)
summary(MSE_model)
#Model 4: CCT_CER Optimal Bandwidth
CER<-rdbwselect(x=RDD_df$IVS,y=RDD_df$beauty,bwselect = "certwo")
CER_df<-bandwidth_implement(RDD_df,-CER$bws[1],CER$bws[2])
CER_model<-IVS_RDD(CER_df)
summary(CER_model)

col_labs=c("Full", "IK", "MSE", "CER")
RDD_models_table<-stargazer(full_model,IK_model,
                            MSE_model,CER_model, digits=0,font.size = "small",
                            column.labels = col_labs)

