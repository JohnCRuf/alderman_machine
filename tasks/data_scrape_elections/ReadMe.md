# Data Scrape Elections
    This task scrapes election data from the Chicago Board of Elections website and saves it as a CSV.

## Output
* `elections.csv`: A CSV file containing precinct-level voting counts for each candidate in each election.
## Code
* `chicago_elections_webscraping_fn.R`: A script that navigates a page of the Chicago Board of Elections website and precinct-level voting counts for each candidate in a given election.
* `elections_webscraping.R`: A script that calls the function in `chicago_elections_webscraping_fn.R` for each link in a list of election data links.
