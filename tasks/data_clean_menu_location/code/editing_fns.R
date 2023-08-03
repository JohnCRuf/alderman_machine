last_keyword_position <- function(x) {
  keyword_positions <- unlist(str_locate_all(tolower(x), "(\\bschool\\b|\\bpark\\b|\\bcenter\\b|\\bfield\\b)"))
  if (length(keyword_positions) == 0) {
    return(as.integer(NA))
  }
  max(keyword_positions)
}

replace_strings_in_df <- function(df, var, replace_vector, detect_vector, exact_match_vector) {
  require(dplyr)
  require(purrr)
  require(stringr)

  for(i in seq_along(detect_vector)){
    df <- df %>% mutate({{var}} := if_else(str_detect({{var}}, names(detect_vector[i])), detect_vector[i], {{var}}))
  }
  

  for(i in seq_along(exact_match_vector)){
    df <- df %>% mutate({{var}} := if_else({{var}} == names(exact_match_vector[i]), exact_match_vector[i], {{var}}))
  }
  

  df <- df %>% mutate({{var}} := str_replace_all({{var}}, replace_vector))
  
  return(df)
}