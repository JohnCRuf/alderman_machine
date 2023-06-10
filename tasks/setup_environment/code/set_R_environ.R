Renviron_location <- readLines("../input/Renviron_location.txt")
api_key <- readLines("../input/google_api_key.txt")
#create api key command for tidygeocoder
command <- paste0("GOOGLEGEOCODE_API_KEY = ", api_key)
#if command is already in Renviron, leave Renviron alone, else append the command to Renviron
if (any(grepl(command, readLines(Renviron_location)))) {
    message("GOOGLEGEOCODE_API_KEY already in Renviron")
} else {
    write(command, Renviron_location, append = TRUE)
    message("GOOGLEGEOCODE_API_KEY added to Renviron")
}

#write confirmation that Renviron has been updated
writeLines(readLines(Renviron_location), "../output/R_environ.txt")