library(tidyverse)
library(stringr)
library(readr)
library(assertr)

menu_df <- read_csv("../input/menu_df.csv")
#Verify that totals are correct
#create dataframe of total spending by ward and year
menu_total_spending_panel <- menu_df %>%
  group_by(ward, year) %>%
  summarise(expenditures = sum(est_cost)) %>%
  mutate(
    expenditures = as.numeric(str_remove_all(expenditures, '"'))
  )
menu_total_spending_scraped <- read_csv("../input/menu_totals.csv") %>%
  mutate(#set scraped to totals without all characters after decimal point
    scraped = as.numeric(total),#if scraped >10,000,000, divide by 100
    scraped = ifelse(scraped > 10000000, scraped/100, scraped),
    total = NULL,
    ward = as.numeric(ward),
    year = as.numeric(year)
  )
#merge scraped and panel data to check for discrepancies
menu_total_spending <- menu_total_spending_panel %>%
  left_join(menu_total_spending_scraped, by = c("ward", "year")) %>%
  mutate(#remove all characters after decimal point in tota
    expenditures = as.numeric(str_remove_all(expenditures, '"')),
    scraped = as.numeric(str_remove_all(scraped, '"'))
  )
#flag each row as correct or incorrect if expenditures and scraped not within 5% of each other
menu_total_spending <- menu_total_spending %>%
  mutate(
    flag = ifelse(abs(expenditures - scraped) < 0.05 * expenditures, "correct", "incorrect")
  )
  #if the number of incorrect rows is greater than 0, write the dataframe to a csv
    if (nrow(menu_total_spending[menu_total_spending$flag == "incorrect", ]) > 0){
        filtered_spending_df<- menu_total_spending %>%
            filter(flag == "incorrect")
        write_csv(filtered_spending_df, "../output/menu_total_spending.csv")
    } else {
        write_csv(menu_total_spending_df, "../output/menu_total_spending.csv")
    }
