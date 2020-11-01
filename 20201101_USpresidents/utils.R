
# functions ---------------------------------------------------------------

is_page <- function(xml_node){
  stopifnot(isClass(xml_node,Class = "xml_node"))
  if (xml2::xml_name(xml_node) == "page"){
    return(TRUE)
  } else {
    return(FALSE)
  }
}

check_status <- function(xml_node){
  ## checks if the node is a Wikipedia article, 0 defaults to that.
  xml_child(x = xml_node,search = ".//d1:ns",ns =  xml_ns(xml_node)) %>% 
    xml_text() %>% 
    as.integer() -> status
  
  if(status == 0){
    return(TRUE)
  } else {
    return(FALSE)
  }
}

get_president_title <- function(xml_node){
  xml_child(x = xml_node,search = ".//d1:title",ns =  xml_ns(xml_node)) -> tp
  xml_text(tp)
}


## master function here
extract_features_president <- function(xml_node) {
  title = get_president_title(xml_node)
  
  if (title == "President of the United States"){
    return(NULL)
  }
  
  xml_child(x = xml_node,
            search = ".//d1:text",
            ns =  xml_ns(xml_node)) %>% 
    xml_text() -> page_text
  
  page_text %>% stringr::str_split("\n") -> lines
  
  stringr::str_extract(string = page_text,
                       "(?<=\\{\\{Infobox )officeholder") -> is_officeholder
  
  

  # capture birth and death dates -------------------------------------------
  pttr="\\{\\{[Dd]eath date and age" 
  purrr::map_lgl(lines[[1]],stringr::str_detect,pattern = pttr) -> lgl_list
  
  idx = which(lgl_list)
  if (length(idx) == 1){
    line = lines[[1]][idx]
    
    pttrn="[:digit:]+\\|[:digit:]+\\|[:digit:]+\\|[:digit:]+\\|[:digit:]+\\|[:digit:]+"
    stringr::str_extract(line,pttrn) -> str_dates
    
    pttrn_death = "[:digit:]+\\|[:digit:]+\\|[:digit:]+"
    stringr::str_extract(str_dates,pttrn_death) -> death_date
    death_date %<>% as.Date(., format = "%Y|%m|%e")
    
    pttrn_birth = "\\|[:digit:]+\\|[:digit:]+\\|[:digit:]+$"
    stringr::str_extract(str_dates,pttrn_birth) -> birth_date
    birth_date %<>% as.Date(., format = "|%Y|%m|%e")
  } else {
    pttr="\\{\\{[bB]irth date and age"
    purrr::map_lgl(lines[[1]],stringr::str_detect,pattern = pttr) -> lgl_list
    line = lines[[1]][which(lgl_list)]
    pttrn_birth = "[:digit:]+\\|[:digit:]+\\|[:digit:]+"
    stringr::str_extract(line,pttrn_birth) -> birth_date
    birth_date %<>% as.Date(., format = "%Y|%m|%e")
    death_date = NA
  }
  
  
  ## this should apply to the alive
  if (length(death_date) == 0){
    
  }
  
  ### date for the terms, the format is diferent 
  ## B is the name of the motnh, need to set  up locale
  ## e is for the name of the day but starting in 1.
  date_format_term = "%B %e, %Y"
  
  pttr = "term_start[:blank:]+=[:blank:][:alnum:]+ [:digit:]+, [:digit:]+"
  stringr::str_extract(string = page_text,pattern = pttr) %>% 
    stringr::str_extract("[:alnum:]+ [:digit:]+, [:digit:]+") -> term_start_date
  term_start_date %<>% as.Date(format = date_format_term)
  
  pttr = "term_end[:blank:]+=[:blank:][:alnum:]+ [:digit:]+, [:digit:]+"
  stringr::str_extract(string = page_text,pattern = pttr) %>% 
    stringr::str_extract("[:alnum:]+ [:digit:]+, [:digit:]+") -> term_end_date
  term_end_date %<>% as.Date(format = date_format_term)
  

  # detect birth place, this is funky ---------------------------------------

  # if (title == "John Adams"){
  #   browser()
  # }

  pttr = "birth_place[:blank:]+=[:space:]+[:graph:]+"
  purrr::map_lgl(lines[[1]],stringr::str_detect,pattern = pttr) -> lgl_list
  
  rownames(USArrests) -> us_states
  states_pttr = paste(us_states, collapse = "|")
  
  line = lines[[1]][which(lgl_list)]
  
  us_state = stringr::str_extract_all(string = line,pattern = states_pttr) %>% 
    unlist() %>% unique()
  if (length(us_state)>1){
    us_state = paste(us_state, collapse = ",")
  }
  is_us_state = !is.na(us_state)
  
  
  data.frame(
    check  = is_officeholder,
    name = title,
    birth_date = birth_date,
    death_date = death_date,
    term_start = term_start_date,
    term_end = term_end_date,
    state = us_state,
    is_us_state = is_us_state
  )
}



parse_president <- function(page) {
  if (!is_page(page)){
    return(NULL)
  }
  
  if (!check_status(page)){
    return(NULL)
  }
  tryCatch(extract_features_president(page),
           error = function(err){print(err); return(NULL)})
  
}




usReg <- tibble::tribble(
  ~state,     ~region,
  "Alabama",     "South",
  "Alaska",      "West",
  "Arizona",      "West",
  "Arkansas",     "South",
  "California",      "West",
  "Colorado",      "West",
  "Connecticut", "Northeast",
  "Delaware", "Northeast",
  "Florida",     "South",
  "Georgia",     "South",
  "Hawaii",      "West",
  "Idaho",      "West",
  "Illinois",   "Midwest",
  "Indiana",   "Midwest",
  "Iowa",   "Midwest",
  "Kansas",   "Midwest",
  "Kentucky",     "South",
  "Louisiana",     "South",
  "Maine", "Northeast",
  "Maryland", "Northeast",
  "Massachusetts", "Northeast",
  "Michigan",   "Midwest",
  "Minnesota",   "Midwest",
  "Mississippi",     "South",
  "Missouri",   "Midwest",
  "Montana",      "West",
  "Nebraska",   "Midwest",
  "Nevada",      "West",
  "New Hampshire", "Northeast",
  "New Jersey", "Northeast",
  "New Mexico",      "West",
  "New York", "Northeast",
  "North Carolina",     "South",
  "North Dakota",   "Midwest",
  "Ohio",   "Midwest",
  "Oklahoma",     "South",
  "Oregon",      "West",
  "Pennsylvania", "Northeast",
  "Rhode Island", "Northeast",
  "South Carolina",     "South",
  "South Dakota",   "Midwest",
  "Tennessee",     "South",
  "Texas",     "South",
  "Utah",      "West",
  "Vermont", "Northeast",
  "Virginia", "Northeast",
  "Washington",      "West",
  "West Virginia", "Northeast",
  "Wisconsin",   "Midwest",
  "Wyoming",      "West"
)


