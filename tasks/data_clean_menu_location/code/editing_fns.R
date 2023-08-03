last_keyword_position <- function(x) {
  keyword_positions <- unlist(str_locate_all(tolower(x), "(\\bschool\\b|\\bpark\\b|\\bcenter\\b|\\bfield\\b)"))
  if (length(keyword_positions) == 0) {
    return(as.integer(NA))
  }
  max(keyword_positions)
}

replace_strings_in_df <- function(df, var, replace_vector = NA, detect_vector = NA, exact_match_vector = NA) {
  require(dplyr)
  require(purrr)
  require(stringr)
  
  # Check if replace_vector is not NA
  if(!is.na(replace_vector)) {
    # Apply the replacements using the replace_vector
    df <- df %>% mutate({{var}} := str_replace_all({{var}}, replace_vector))
  }
  
  # Check if detect_vector is not NA
  if(!is.na(detect_vector)) {
    # Check for the detect_vector and replace those strings if detected
    for(i in seq_along(detect_vector)){
      df <- df %>% mutate({{var}} := if_else(str_detect({{var}}, names(detect_vector[i])), detect_vector[i], {{var}}))
    }
  }
  
  # Check if exact_match_vector is not NA
  if(!is.na(exact_match_vector)) {
    # Apply exact matches from the exact_match_vector
    for(i in seq_along(exact_match_vector)){
      df <- df %>% mutate({{var}} := if_else({{var}} == names(exact_match_vector[i]), exact_match_vector[i], {{var}}))
    }
  }
  
  return(df)
}