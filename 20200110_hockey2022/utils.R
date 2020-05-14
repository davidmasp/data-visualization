#!/usr/bin/env Rscript

# Name: utils
# Author: DMP
# Description: Vizz the relationship with temperature and hockey score
# File description: Contain a set of functions that will be imported in the
# analysis contained in this folder

# functions ------------------------------------------------------------------

hello <- function(){
    message("Hello DMP!")
}

# helpers --------------------------------------------------------------------

check_deps <- function(){
    stopifnot(requireNamespace("renv"))
    r_files=list.files(path = ".",pattern = "*.R$")
    deps = unique(
        unlist(
            lapply(r_files,
                   function(x){renv::dependencies(x)[["Package"]]})))
    stopifnot(all(unlist(lapply(deps,requireNamespace))))
}

getParamsTable <- function(toFile) {
  obj = ls(envir = .GlobalEnv)
  mask = grepl(pattern = "params",x = obj)

  params_values = sapply(X = obj[mask], get)

  jsonlite::toJSON(x = params_values,
                   auto_unbox = TRUE,
                   pretty = TRUE) -> json_text

  readr::write_lines(x = json_text,path = toFile)

}

