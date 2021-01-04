

# utils -------------------------------------------------------------------

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


get_page_title <- function(page){
  tmp_kfhsdkj <- xml_child(x = page,
                           search = ".//d1:title",
                           ns = xml_ns(page))
  xml_text(tmp_kfhsdkj) -> title_text
  return(title_text)
}



extract_data_workflow <- function(fn,type) {
  
  xml2::read_xml(fn) -> wiki_imp
  
  pattr = "[Bb]irth date[ and age]*[\\|mf=yes]*\\|[:digit:]+\\|[:digit:]+\\|[:digit:]+"
  
  children <- xml_children(wiki_imp)
  library(progress)
  pb <- progress_bar$new(total = length(children),
                         format = ":percent [:bar] eta: :eta | elapsed: :elapsed",
                         clear = FALSE,
                         width= cli::console_width())
  
  children %>% purrr::map(function(wiki_page){
    
    # this goes inside the iteration
    pb$tick()
    
    if (!is_page(wiki_page)){
      return(NULL)
    }
    
    get_page_title(wiki_page) -> page_title
    
    xml_child(x = wiki_page,
              search = ".//d1:text",
              ns = xml_ns(wiki_page)) -> text_child
    
    stringr::str_extract(string = xml_text(text_child),
                         pattern = pattr) -> value_birth_date
    
    tibble::tibble(
      name = page_title,
      birth_date = value_birth_date
    )
    
  }) -> parsed_vals
  
  
  parsed_vals <- dplyr::bind_rows(parsed_vals)
  
  stringr::str_extract(parsed_vals$birth_date,
                       pattern = "[:digit:]+\\|[:digit:]+\\|[:digit:]+") -> dates
  
  parsed_vals$dates = dates
  
  ol = nrow(parsed_vals)
  parsed_vals <- parsed_vals[!is.na(parsed_vals$birth_date),]
  el = nrow(parsed_vals)
  
  scales::percent(el/ol) -> perc_of_good_parsed
  print(perc_of_good_parsed)
  
  parsed_vals %>% tidyr::separate(col = dates,
                                  into = c("year","month","day"),
                                  convert = TRUE) -> df
  df$birth_date <- with(df,glue::glue("{year}-{month}-{day}"))
  
  df$birth_date <- as.Date(x = df$birth_date)
  
  # this is arbitrary
  lubridate::week(df$birth_date) -> week_time
  df$week <- week_time
  
  df$month2 = lubridate::month(df$birth_date)
  
  total <- nrow(df)
  
  print(total)
  
  df %>% dplyr::group_by(month) %>% 
    dplyr::summarise(n=dplyr::n(),
                     perc = n / total) -> plot_data
  
  plot_data$type = type
  
  plot_data
  
}

