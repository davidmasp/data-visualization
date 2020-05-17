

# imports -----------------------------------------------------------------

library(ggplot2)
library(ggrepel)
library(dplyr)
library(scales)


# region helpers ----------------------------------------------------------

# building the region
tri.df <- data.frame(votes.per = c(0,1,1),
                     seats.per = c(0,1,0) ) 

# data processing ---------------------------------------------------------

dat <- read.table("data/nationals.csv",
                    header = TRUE,
                    sep=";")

dat$election <- as.Date(dat$election, origin="1899-12-30")
total.votes = sum(dat$votes)
total.seats = sum(dat$seats)
dat$votes.per <- dat$votes / total.votes
dat$seats.per <- dat$seats / total.seats
dat$party <- as.factor(dat$party)

dat$party_label = paste(dat$party,format(dat$election,"%Y"),sep = " - ")

opt_choices = levels(dat$party) %>% as.list()
names(opt_choices) = unlist(opt_choices)

# colors ------------------------------------------------------------------


colors <- c("Amaiur" = "#0198B3",
               "Bildu" = "#BDD016",
               "BNG" = "#6EC9FF",
               "CC" = "#FFED03", 
               "CDC" = "darkblue", 
               "Compromis" = "orange", 
               "Cs" = "#F17A36", 
               "EB" = "grey", 
               "ECP" = "blueviolet", 
               "EnMarea" = "blue4", 
               "EQUO"="green4", 
               "ERC" = "orange", 
               "Foro" = "royalblue4", 
               "GeroaBai" = "#4dff4d", 
               "IU" = "red2", 
               "PA" = "palegreen2", 
               "PACMA" = "palegreen4",
               "PNV" = "#419653",
               "PODEMOS" = "darkmagenta",
               "PP" = "dodgerblue3",
               "PRC" = "darkred",
               "PSOE" = "red2",
               "PxC" = "paleturquoise3",
               "UPYD" = "violetred1",
               "GeroaBai" = "seagreen1",
               "CiU" = "#000099",
               "DL" = "#0000b3",
               "UP" = "darkmagenta")
