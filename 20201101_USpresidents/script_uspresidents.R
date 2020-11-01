

# imports -----------------------------------------------------------------

library("xml2")
library(magrittr)
source("utils.R")

x <- read_xml("USpresidents.xml")

# globals -----------------------------------------------------------------
Sys.setlocale("LC_ALL","English")

xml_children(x) %>% 
  purrr::map(parse_president) %>% 
  dplyr::bind_rows() -> results_df

# results_df
sum(is.na(results_df$birth_date))
nrow(results_df)

manual_fix = gsub(pattern = "Washington,Virginia",
                  replacement = "Virginia",x = results_df$state
                  )

manual_fix = gsub(pattern = "North Carolina,South Carolina",
                  replacement = "South Carolina",x = manual_fix
)

results_df$state = manual_fix

dplyr::group_by(results_df,state) %>% dplyr::tally() -> tally


saveRDS(object = results_df,file = "data.rds")

