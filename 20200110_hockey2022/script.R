#!/usr/bin/env Rscript

# Name: 0-wrangle
# Author: DMP
# Description: wrangle data for the hockey2020 project.

# imports -----------------------------------------------------------------

source("imports.R") # this also imports utils.R (first)

# params ------------------------------------------------------------------

source("params.R")
text_size = 8

# data --------------------------------------------------------------------
# This section should contain data import code
id_file = Sys.getenv("id_file")
base_url = "https://docs.google.com/spreadsheets/d"
base_export="export?format=xlsx"
url = glue::glue("{base_url}/{id_file}/{base_export}")

curl_download(url, "data.xlsx")

data_points <- readxl::read_excel("data.xlsx",sheet = "Hockey2020_points")
data_temp <- readxl::read_excel("data.xlsx",sheet = "Temperatures")

# script ------------------------------------------------------------------
# This section should contain transformation and wrangling of the data.

dplyr::left_join(data_points,data_temp) -> dat

dat %>%
  dplyr::filter(is.na(average_yearly_temperature)) -> tmp
stopifnot(nrow(tmp) == 0)


# test
cor.test(dat$total,dat$average_yearly_temperature) %>%
  broom::tidy() -> cor_values
cor_values$estimate = round(cor_values$estimate,digits = 2)

title_text = glue::glue(
  "Qualifying points for the 2022 Ice Hockey olympics  vs. Temperature (r = {cor_values$estimate}, pval  = {scales::pvalue(cor_values$p.value)})")

ggplot(dat,aes(x = total,
               color = qualified_group,
               y = average_yearly_temperature)) +
  geom_point() +
  geom_smooth(method = "lm",
              color = "black",
              linetype = "dashed") +
  ggrepel::geom_text_repel(aes(label = Country),
                           size = text_size / ggplot2::.pt) +
  labs(title = title_text,
       x ="Total points",
       color = "Qualifying group",
       y = "Average Yearly Temperature")+
  scale_color_brewer(palette = "Set1",
                     na.value = "gray35") +
  scale_x_continuous(labels = scales::comma) +
  theme_classic() +
  theme(text = element_text(size = text_size))


ggsave(filename = "correlation_plot.png",
       device = "png",
       dpi = "retina",
       width = 8,height = 6)
