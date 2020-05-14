#!/usr/bin/env Rscript

# Name: imports
# Author: DMP
# Description: Vizz the relationship with temperature and hockey score
# File description: File to import general libraries to the whole
# analysis. This mantains a common import script. For specific packages
# that need to be imported in only one script use a import section there.

# imports -----------------------------------------------------------------
source("utils.R")
check_deps()

# this package is used for the pipe..
library(magrittr)
library(curl)
library(ggplot2)
