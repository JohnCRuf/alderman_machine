#John Ruf 05/05/22
#This code is intended to process the elections data and present a list of incumbents for each election
#A list of appointments is used since we don't have direct data on who was the incumbent for each election.


library(tidyverse)
library(stringr)
library(readr)
library("rstudioapi") 
setwd(dirname(getActiveDocumentContext()$path)) 
elections <- read_csv("../input/elections.csv")%>%
  mutate(Candidate=gsub("  ", " ",Candidate),
         Candidate=gsub("Patricia ''Pat'' Dowell", "Pat Dowell",Candidate),
         Candidate=gsub("Thomas M. Tunney", "Tom Tunney",Candidate),
         Candidate=gsub("Rey Colãƒâ³N", "Rey Colon",Candidate))

#Step 1: Get the set of winners for each race

election_group<-elections %>%
  group_by(year, Ward, type,Candidate) %>%
  summarize(total_votes_percandidate=sum(Votecount))

election_winners<-election_group %>%
  group_by(year,Ward,type) %>%
  summarize(Candidate,
            votepct=total_votes_percandidate/sum(total_votes_percandidate)) %>%
  mutate(winner=ifelse(votepct>0.5,1,0))
election_winners_df<-election_winners%>%
  filter(winner==1)
winners=as.data.frame(unique(election_winners_df$Candidate))

#Extract winning candidates and all candidates
election_winner_list<-vector(mode="list",length=5)
election_candidate_list<-vector(mode="list",length=5)
for(i in 1:length(unique(elections$year))){
  elections_year_winners<-election_winners %>%
    filter(winner==1, year==unique(elections$year)[i])
  election_candidate_year<-election_winners %>%
    filter(year==unique(elections$year)[i])
  election_winner_list[[i]]=unique(elections_year_winners$Candidate)
  election_candidate_list[[i]]=unique(election_candidate_year$Candidate)
}
election_winner_list[[6]]<-unique(elections$year)


#Step 2: Get list of 2019 Incumbents

incumbents_2019=intersect(election_winner_list[[2]],election_candidate_list[[1]])
appointments_2019=c('Silvana Tabares')
incumbents_2019=append(incumbents_2019, appointments_2019)
incumbents_2019=append(incumbents_2019, election_winner_list[[5]])

#Step 3: Get list of 2015 Incumbents

incumbents_2015=intersect(election_winner_list[[3]],election_candidate_list[[2]])
appointments_2015=c('Deborah L. Mell', 'Natashia L. Holmes')
incumbents_2015=append(incumbents_2015, appointments_2015)

#Step 4: Get list of 2011 Incumbents

incumbents_2011=intersect(election_winner_list[[4]],election_candidate_list[[3]])
appointments_2011=c("Proco ''Joe'' Moreno", "Roberto Maldonado", "Deborah L. Graham", "Jason C. Ervin", "John A. Rice","Timoth y M. Cullerton")
incumbents_2011=append(incumbents_2011, appointments_2011)

incumbents_list<-vector(mode="list",length=3)
incumbents_list[[1]]<-incumbents_2019
incumbents_list[[2]]<-incumbents_2015
incumbents_list[[3]]<-incumbents_2011


#Step 5: Develop Incumbent VS Dataset
incumbent_vs<-election_winners %>%
  mutate(winner=NULL,
         inc_2019=ifelse(Candidate %in% incumbents_list[[1]],1,0),
         inc_2015=ifelse(Candidate %in% incumbents_list[[2]],1,0),
         inc_2011=ifelse(Candidate %in% incumbents_list[[3]],1,0))
incumbent_df_2019<-incumbent_vs%>%
  filter(year==2019,inc_2019==1)
incumbent_df_2015<-incumbent_vs%>%
  filter(year==2015,inc_2015==1)
incumbent_df_2011<-incumbent_vs%>%
  filter(year==2011,inc_2011==1)

incumbent_vs_df<-rbind(incumbent_df_2019,incumbent_df_2015,incumbent_df_2011)

saveRDS(incumbents_list, file="../output/incumbents_list.RDS")

write_csv(incumbent_vs_df, file="../output/incumbent_voteshare_df.csv")
