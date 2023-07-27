ordinal_suffix <- function(n) {
  #This function takes in a number and returns the appropriate ordinal suffix
  # Suffix for 11, 12, 13 regardless of the last digit
  suffix <- ifelse(n %% 100 %in% c(11, 12, 13), "th",
                   # Suffix for 1, 2, 3 when not preceded by 11, 12, 13
                   ifelse(n %% 10 == 1, "st",
                          ifelse(n %% 10 == 2, "nd",
                                 ifelse(n %% 10 == 3, "rd", "th"))))
  return(suffix)
}

replace_with_ordinal <- function(s) {
  # This pattern matches "W ### ST", "E ### PL", "& ### ST", "& ### PL" 
  # and "W ### (ST|ND|TH|RD) ST", "E ### (ST|ND|TH|RD) PL", "& ### (ST|ND|TH|RD) ST", "& ### (ST|ND|TH|RD) PL" 
  pattern <- "(\\b[W|E|&]\\s+)(\\d+)(\\s+ST|\\s+PL|\\s+ST|\\s+PL|\\s+(ST|ND|TH|RD)\\s+ST|\\s+(ST|ND|TH|RD)\\s+PL)"
  
  s <- str_replace_all(s, pattern, function(match) {
    parts <- str_split(match, "\\s+")[[1]]
    
    # The number is at the 2nd position in the parts
    number <- as.integer(parts[2])
    
    # Convert the number to its ordinal form
    ordinal_number <- paste0(number, ordinal_suffix(number))
    
    # Check if suffix already exists, if it does, update it
    if (tolower(parts[length(parts) - 1]) %in% c("st", "nd", "rd", "th")) {
      # Replace the existing suffix with its lowercase form, joined to the number
      parts[2] <- paste0(number, tolower(parts[length(parts) - 1]))
      parts[length(parts) - 1] <- ""
      
      replacement <- paste(parts[1:length(parts)], collapse = " ")
    } else {
      # Replace the number with its ordinal form and join with "ST" or "PL"
      # The suffix is the last word
      suffix <- parts[length(parts)]
      
      replacement <- paste0(parts[1], " ", ordinal_number, " ", suffix)
    }
    
    return(replacement)
  })
  
  # Remove any extra spaces
  s <- str_replace_all(s, "\\s{2,}", " ")
  
  return(s)
}

# Function to add ordinal indicators
add_ordinal_indicator <- function(df, var_name) {
  df %>%
    mutate(!!sym(var_name) := map_chr(!!sym(var_name), replace_with_ordinal))
}