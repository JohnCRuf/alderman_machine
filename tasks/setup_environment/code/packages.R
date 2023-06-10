packages <- c("tidyverse", "RSelenium", "stargazer","stringr", "XML",
 "rstudioapi", "ggplot2", "rdd", "XML", "did", "rvest", "rdrobust",
  "assertthat", "tidygeocoder", "usethis")

# Create a directory for  packages
dir.create(path = Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)

i <- 1
output <- NA
for (package in packages) {
  if (require(package, character.only = TRUE) == FALSE) {
    install.packages(package, lib = Sys.getenv("R_LIBS_USER"),
                     repos = "http://cran.us.r-project.org")
    message(paste("Installing", package, sep = ""))
  }
  version <- packageDescription(package, fields = "Version")
  output[i] <- paste(package, version, sep = " : ")
  print(output)
  i <- i + 1
}

output <- paste(output, collapse = "\n")
output <- paste("Packages installed: ", output, sep = "\n")
write.table(output, "../output/R_packages.txt", col.names = FALSE, row.names = FALSE)

census_api_key <- readLines("../input/census_api_key.txt")
google_api_key <- readLines("../input/google_api_key.txt")
library("assertthat")
assert_that(census_api_key != "")
assert_that(google_api_key != "")


set_string_google <- paste0("GOOGLEGEOCODE_API_KEY = \"", google_api_key, "\"")
set_string_census <- paste0("CENSUS_API_KEY = \"", census_api_key, "\"")

#Create R profile file in ../../.Rprofile if it doesn't exist
if (!file.exists("../../.Rprofile")) {
  file.create("../../.Rprofile")
} 

if (!any(grepl(set_string_google, readLines("../../.Rprofile")))) {
  write(set_string_google, file = "../../.Rprofile", sep = "\n", append = TRUE)
}

if (!any(grepl(set_string_census, readLines("../../.Rprofile")))) {
  write(set_string_census, file = "../../.Rprofile", sep = "\n", append = TRUE)
}

write("R keys were successfully set", "../output/R_keys_set.txt")