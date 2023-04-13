library(tidyverse)
library(stringr)
library(readr)

elections <- read_csv("../input/elections.csv")%>%
  mutate(Candidate=gsub("  ", " ",Candidate),
         Candidate=gsub("Patricia ''Pat'' Dowell", "Pat Dowell",Candidate), #remove misnamed candidates
         Candidate=gsub("Thomas M. Tunney", "Tom Tunney",Candidate),
         Candidate=gsub("Rey Col????????N", "Rey Colon",Candidate))

# Get the set of winners for each race
election_group<-elections %>%
  group_by(year, Ward, type,Candidate) %>%
  summarize(total_votes_percandidate=sum(Votecount))

election_winners_df<-election_group %>%
  group_by(year,Ward,type) %>%
  summarize(Candidate,
            votepct=total_votes_percandidate/sum(total_votes_percandidate)) %>%
  mutate(winner=ifelse(votepct>0.5,1,0))
election_winners_df_filtered<-election_winners_df%>%
  filter(winner==1)

winners=as.data.frame(unique(election_winners_df_filtered$Candidate))

#Extract winning candidates and all candidates
election_winner_list<-vector(mode="list",length=5)
election_candidate_list<-vector(mode="list",length=5)
year_vector <-sort(unique(elections$year), decreasing = TRUE)
j = 1
for(i in year_vector){
  elections_year_winners<-election_winners %>%
    filter(winner==1, year==i)
  election_candidate_year<-election_winners %>%
    filter(year==i)
  election_winner_list[[j]]=unique(elections_year_winners$Candidate)
  election_candidate_list[[j]]=unique(election_candidate_year$Candidate)
  j=j+1
}

incumbents_2019_a=intersect(election_winner_list[[which(year_vector==2017)]],election_candidate_list[[which(year_vector==2019)]])
incumbents_2019_b=intersect(election_winner_list[[which(year_vector==2015)]],election_candidate_list[[which(year_vector==2019)]])
appointments_2019=c('Silvana Tabares')
incumbents_2019=union(incumbents_2019_a, union(appointments_2019, incumbents_2019_b))

#Get list of 2015 Incumbents

incumbents_2015=intersect(election_winner_list[[which(year_vector==2011)]],election_candidate_list[[which(year_vector==2015)]])
appointments_2015=c('Deborah L. Mell', 'Natashia L. Holmes')
incumbents_2015=append(incumbents_2015, appointments_2015)
print(incumbents_2015)

#Get list of 2011 Incumbents

incumbents_2011=intersect(election_winner_list[[which(year_vector==2007)]],election_candidate_list[[which(year_vector==2011)]])
appointments_2011=c("Proco ''Joe'' Moreno", "Roberto Maldonado", "Deborah L. Graham", "Jason C. Ervin", "John A. Rice","Timothy M. Cullerton")
incumbents_2011=append(incumbents_2011, appointments_2011)

incumbents_2007=intersect(election_winner_list[[which(year_vector==2003)]],election_candidate_list[[which(year_vector==2007)]])
appointments_2007=c("Darcel A. Beavers","Lona Lane", "Thomas W. Murphy", "Thomas M. Tunney")
incumbents_2007=append(incumbents_2007, appointments_2007)

appointments_2003=c("Todd H. Stroger", "Latasha R. Thomas", "Emma M. Mitts")
incumbents_2003=c("Rafael ''Ray'' Frias", "Dorothy J. Tillman", "Toni Preckwinkle", "Leslie A. Hairston", "Freddrenna M. Lyle", "William M. Beavers", "Anthony A. Beale", "John A. Pope", "James A. Balcer", "Frank J. Olivo",  "Theodore ''Ted'' Thomas", "Shirley A. Coleman", "Virginia A. Rugai", "Arenda Troutman", "Leonard Deville", "Ricardo Munoz", "Michael R. Zalewski", "Michael D. Chandler","Daniel ''Danny'' Solis", "Billy Ocasio", "Walter Burnett, Jr.", "Ed H. Smith", "Isaac ''Ike'' Sims Carothers", "Regner ''Ray'' Suarez", "Ted Matlak", "Richard F. Mell", "Carrie M. Austin", "Vilma Colom", "William J.p. Banks", "Thomas R. Allen", "Margaret Laurino", "Patrick J. O'connor", "Brian G. Doherty", "Burton F. Natarus", "Vi Daley", "Helen Shiller", "Gene Schulter", "Joe Moore", "Bernard L. Stone", "Jesse D. Granato")
incumbents_2003=append(incumbents_2003, appointments_2003)

#Get list of all incumbents
incumbents_all=intersect(unique(elections$year),election_candidate_list)
incumbents_all=append(incumbents_all, appointments_2019)
incumbents_all=append(incumbents_all, appointments_2015)
incumbents_all=append(incumbents_all, appointments_2011)
incumbents_all=append(incumbents_all, appointments_2007)
incumbents_all=append(incumbents_all, appointments_2003)
#Develop Incumbent VS Dataset
incumbent_vs<-election_winners %>%
  mutate(winner=NULL,
         inc_2019=ifelse(Candidate %in% incumbents_2019,1,0),
         inc_2015=ifelse(Candidate %in% incumbents_2015,1,0),
         inc_2011=ifelse(Candidate %in% incumbents_2011,1,0),
         inc_2007=ifelse(Candidate %in% incumbents_2007,1,0),
         inc_2003=ifelse(Candidate %in% incumbents_2003,1,0))
incumbent_df_2019<-incumbent_vs%>%
  filter(year==2019,inc_2019==1)
incumbent_df_2015<-incumbent_vs%>%
  filter(year==2015,inc_2015==1)
incumbent_df_2011<-incumbent_vs%>%
  filter(year==2011,inc_2011==1)
incumbent_df_2007<-incumbent_vs%>%
  filter(year==2007,inc_2007==1)
incumbent_df_2003<-incumbent_vs%>%
  filter(year==2003,inc_2003==1)


incumbent_vs_df<-rbind(incumbent_df_2019,incumbent_df_2015,incumbent_df_2011, incumbent_df_2007, incumbent_df_2003)

#Create List of incumbents
incumbents_list<-vector(mode="list",length=5)
incumbents_list[[1]]<-incumbents_2019
incumbents_list[[2]]<-incumbents_2015
incumbents_list[[3]]<-incumbents_2011
incumbents_list[[4]]<-incumbents_2007
incumbents_list[[5]]<-incumbents_2003
saveRDS(incumbents_list, file="../output/incumbents_list.RDS")
saveRDS(incumbents_all, file="../output/incumbents_all.RDS") #TODO: Add more appointments

write_csv(incumbent_vs_df, file="../output/incumbent_voteshare_df.csv")

#Write aggregate candidate dataframe
aggregate_candidate_df <- election_winners_df %>%
  left_join(incumbent_vs_df, by=c("Candidate", "year", "Ward", "type","votepct")) %>%
  mutate(inc_2019=ifelse(is.na(inc_2019),0,inc_2019),
         inc_2015=ifelse(is.na(inc_2015),0,inc_2015),
         inc_2011=ifelse(is.na(inc_2011),0,inc_2011),
         inc_2007=ifelse(is.na(inc_2007),0,inc_2007),
         inc_2003=ifelse(is.na(inc_2003),0,inc_2003))
write_csv(aggregate_candidate_df, file="../output/aggregate_candidate_df.csv")