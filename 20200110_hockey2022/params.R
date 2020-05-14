#!/usr/bin/env Rscript

# Name: params
# Author: DMP
# Description: Vizz the relationship with temperature and hockey score
# File description: File to unify parameters in the whole document. Params that
# are only relevant for defined scripts should be kept in those particular files
# in the params section

# params ------------------------------------------------------------------
author = "DMP!"
# example:
# k = 1

# output ------------------------------------------------------------------

## comment any non-needed folder
today = Sys.Date()
current_dir = getwd()
results_path = fs::path(current_dir,"results","hockey2020",today)
results_path_lt = fs::path(current_dir,"results","hockey2020","latest")
tables_path = fs::path(current_dir,"tables","hockey2020",today)
tables_path_lt = fs::path(current_dir,"tables","hockey2020","latest")
figures_path = fs::path(current_dir,"figures","hockey2020",today)
figures_path_lt = fs::path(current_dir,"figures","hockey2020","latest")

## create files, the fs directive is save if existsing. 
fs::dir_create(results_path)
fs::dir_create(results_path_lt)
fs::dir_create(tables_path)
fs::dir_create(figures_path)
fs::dir_create(figures_path_lt)

params_hash = tools::md5sum("params.R")
getParamsTable(toFile = fs::path(results_path,glue::glue("{params_hash}.json")))
getParamsTable(toFile = fs::path(results_path_lt,glue::glue("{params_hash}.json")))
