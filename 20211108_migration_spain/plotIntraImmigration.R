#!/usr/bin/env Rscript

# Name: plotIntraImmigration.R
# Author: DMP
# Description:

# imports -----------------------------------------------------------------

library(jsonlite)
library(magrittr)

# params ------------------------------------------------------------------

path <- "immigration_spain_intra.json"
jsonlite::fromJSON(path, simplifyDataFrame = FALSE) -> dat

path2 <- "total_population.json"
jsonlite::fromJSON(path2, simplifyDataFrame = FALSE) -> dat_pob

# data --------------------------------------------------------------------

gdp = readr::read_csv("gdp.csv")

dat %>% purrr::map_df(function(x){
  name = x$MetaData[[1]]$Nombre
  x$Data %>% purrr::map_int("Anyo") -> year
  x$Data %>% purrr::map_chr("Valor") -> value
  value %>% stringr::str_replace(".000000","") %>% as.integer() -> value_int
  data.frame(
    name = name,
    year = year,
    value = value_int
  )
}) -> dat_df

dat_pob %>% purrr::map_df(function(x){
  name = x$MetaData[[4]]$Nombre
  x$Data %>% purrr::map_int("Anyo") -> year
  x$Data %>% purrr::map_chr("Valor") -> value
  value %>% stringr::str_replace(".000000","") %>% as.integer() -> value_int
  data.frame(
    name = name,
    year = year,
    pob = value_int
  )
}) -> dat_pob_df


# script ------------------------------------------------------------------

library(ggplot2)

breaks_x = seq(min(dat_df$year),
               max(dat_df$year))

selected = c("Madrid, Comunidad de",
             "Castilla y León",
             "Castilla - La Mancha",
             "Andalucía")


colors_gdp = c(
   "recession"= "#e41a1c",
   "flat" = "#377eb8",
   "growth" = "#4daf4a")

colors = c(
  "#ff7f00",
  "#ff7f00",
  "#ff7f00",
  "#6a3d9a"
)

names(colors) = c(selected, "Other")

dat_df$label = ifelse(
  dat_df$name %in% selected,
  dat_df$name,
  "Other"
)

dat_df %>%
  dplyr::filter(label != "Other") %>%
  dplyr::top_n(1, year) -> label_df

dat_df %>%
  dplyr::filter(label != "Other") %>%
  ggplot(aes(x = year, y = value, group = name, color = label)) +
  geom_point(size = 2) +
  geom_line() +
  geom_hline(yintercept = 0) +
  ggrepel::geom_text_repel(data = label_df,
                           nudge_x = 100,
                           aes(label = label)) +
  scale_color_manual(values = colors ) +
  scale_x_continuous(breaks = breaks_x,
                     expand = expansion(mult = c(0,0), add = c(0,5))) +
  theme_classic() +
  theme(axis.ticks = element_blank()) +
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.5)) +
  labs(y = "Internal net migration between regions (Spain)",
       x = "") +
  theme(legend.position = "none")-> p1

dat_df %>%
  dplyr::select(-label) %>%
  tidyr::pivot_wider(names_from = name, values_from = value) %>%
  dplyr::mutate(Madrid = `Madrid, Comunidad de`,
                Castillas_Andalucia = `Castilla y León` + `Castilla - La Mancha` + `Andalucía`) %>%
  dplyr::select(year, Madrid, Castillas_Andalucia) -> plot_tmp

plot_tmp %<>% dplyr::left_join(gdp)

plot_tmp$gdp_label = dplyr::case_when(
  plot_tmp$gdp_change > -1 & plot_tmp$gdp_change < 1  ~ "flat",
  plot_tmp$gdp_change >= 1 ~ "growth",
  plot_tmp$gdp_change <= -1 ~ "recession"
)

plot_tmp %>%
  ggplot(aes(x = Madrid, y = Castillas_Andalucia, color = gdp_label)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE,  color = "black", linetype = "dashed") +
  ggrepel::geom_text_repel(aes(label = year)) +
  theme_classic() +
  theme(axis.line = element_blank()) +
  scale_color_manual(values = colors_gdp) +
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = 0) +
  labs(color = "") +
  theme(axis.ticks = element_blank(),
        legend.position = "top") +
  labs(y = "Castillas + Andalucía") -> p2


library(patchwork)
p1 + p2
ggsave(filename = "main.pdf", width = 8, height = 5)

# section2  ---------------------------------------------------------------



dat_df %<>% dplyr::group_by(name) %>%
  dplyr::arrange(year) %>%
  dplyr::mutate(cumulative_change = cumsum(value))

dplyr::left_join(dat_df, dat_pob_df) -> plot_dat

selected2 = c(
  "Ceuta",
  "Melilla",
  "Castilla y León",
  "Extremadura",
  "Madrid, Comunidad de",
  "Balears, Illes"
)

plot_dat %<>%
  dplyr::mutate(label = ifelse(name %in% selected2,
                               name,
                               "Other"))

plot_dat %>%
  dplyr::filter(name %in% selected2) %>%
  dplyr::top_n(1, year) -> label_df




plot_dat %>%
  ggplot(aes(x = year,
             y = cumulative_change/pob,
             color = label,
             group = name)) +
  #geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_smooth(se = F) +
  #geom_line(size = 1) +
  ggrepel::geom_text_repel(data = label_df,
                           nudge_x = 100,
                           direction = "y",
                           aes(label = name, color = label),
                           segment.colour = "gray",
                           size = 8/ggplot2::.pt) +
  scale_x_continuous(breaks = breaks_x,
                     expand = expansion(mult = c(0,0), add = c(0,3))) +
  scale_y_continuous(labels = scales::percent) +
  theme_classic() +
  labs(title = "Cumulative inter-state migration (Spain)",
       y = "Proportion of total population", x = "") +
  theme(legend.position = "none")

ggsave("test.pdf", width = 6, height = 5)
