library(tidyverse)
library(tidygeocoder)
source("../input/geocode_function.R")
ARGS <- commandArgs(trailingOnly = TRUE)
# ARGS <- c("../input/burke_receipts.csv", "../output/burke_receipts_geocoded.csv")
df <- read_csv(ARGS[1])

# Remove all rows where State is not IL
df <- df %>%
  filter(State == "IL")

# Filter to where D2Part is "individual contribution," City contains "Chicago" (case-insensitive),
# and Description does not contain specific phrases
df <- df %>%
  filter(grepl("individual contribution", D2Part, ignore.case = TRUE) &
           grepl("chicago", City, ignore.case = TRUE) &
           !grepl("investment|interest|dividend|reimbursement", Description, ignore.case = TRUE))


geocoded_df <- menu_geocode(df, "Address1", 1000)
#replace all obviously non-Chicago coordinates with NA
geocoded_df <- filter_chicago_coordinates(geocoded_df)
#keep amount. address1, address2, address3, Rcvd date, RptPdBegDate, RptPdEndDate, FiledRcvdDate, lat, long, and query
geocoded_df <- geocoded_df %>%
  select(Amount, Address1, Address2, Zip, RcvdDate, RptPdBegDate, RptPdEndDate, FiledRcvdDate, lat, long, query)
write_csv(geocoded_df, ARGS[2])