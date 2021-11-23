#!/usr/bin/env Rscript

# Name: Country elections uk
# Author: DMP
# Description:

# imports -----------------------------------------------------------------

library(magrittr)
library(ggplot2)

# params ------------------------------------------------------------------

path = "data/Southend_West_election_results - elections.csv"

colors = c(
  Libdems = "#FAA61A",
  Labour = "#AF0A2C",
  Conservative = "#0087DC",
  UKIP = "#7f2d88",
  Other = "gray80"
)

# data --------------------------------------------------------------------

dat = readr::read_csv(path)

# script ------------------------------------------------------------------

dat$party_summ = ifelse(
  dat$party %in% c("Liberal Democrats", "Liberal"),
  "Libdems",
  dat$party
)

dat$party_summ = ifelse(
  dat$party_summ %in% c("Labour Co-op"),
  "Labour",
  dat$party_summ
)

major_parties = c(
  "Conservative",
  "Labour",
  "Libdems",
  "UKIP"
)

dat$party_summ = ifelse(
  dat$party_summ %in% major_parties,
  dat$party_summ,
  "Other"
)

dat$party_summ %<>% forcats::fct_relevel(.f = .,  names(colors))

dat %<>% dplyr::group_by(year, elec_n) %>%
  dplyr::mutate(total_votes = sum(votes),
                total_perc = sum(percent),
                actual_perc = votes/total_votes)

ggplot(dat, aes(x = year,
                y = votes,
                color = party_summ)) +
  geom_line(data = subset(dat, party == "Conservative"),
            aes(group = candidate), size = 1) +
  geom_point(data = subset(dat, party == "Conservative"), size=2) +
  scale_x_continuous(breaks = unique(dat$year)) +
  scale_y_continuous(labels = scales::comma) +
  scale_color_manual(values = colors) +
  theme_classic() +
  labs(color = "Party") +
  geom_smooth(se = F, linetype = "dashed", size = 1) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  theme(panel.grid.major.x = element_line(linetype = "dashed"),
        legend.position = "top")

ggsave(filename = "plot.svg",width = 7,height = 5)
