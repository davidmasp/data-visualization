library(ggplot2)
library(ggrepel)

el.df <- read.table("data/nationals.csv", header = TRUE,sep=";")
el.df$election <- as.Date(el.df$election, origin="1899-12-30")
total.votes = sum(el.df$votes)
total.seats = sum(el.df$seats)
el.df$votes.per <- el.df$votes / total.votes
el.df$seats.per <- el.df$seats / total.seats
el.df$party <- as.factor(el.df$party)







