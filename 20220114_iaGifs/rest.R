#!/usr/bin/env Rscript

# Name: 
# Author: 
# Description: 

# imports -----------------------------------------------------------------

library(ggplot2)
library(magrittr)

# params ------------------------------------------------------------------

min_date = as.Date("2021-10-15")
ca_ex = c("CE","ML")

# data --------------------------------------------------------------------

dat = readr::read_csv(file = "Downloads/casos_tecnica_ccaa.csv")

# script ------------------------------------------------------------------

dat$total = apply(dat[,3:ncol(dat)],1, sum)

dat %>% dplyr::select(ccaa_iso, fecha, total) %>% 
  tidyr::pivot_wider(names_from = ccaa_iso, values_from = total) -> dat_wide

dat %<>% 
  dplyr::group_by(ccaa_iso) %>% 
  dplyr::mutate(total7mean = zoo::rollmean(total, k = 7, fill = NA),
                total14mean = zoo::rollmean(total, k = 14, fill = NA),
                rratio = roll_ratio(total7mean, k = 7))

ggplot(dat, aes(y = total14mean, color = ccaa_iso, x = fecha)) +
  geom_line() +
  theme_classic() +
  scale_y_continuous(expand = expansion())

dat$label = ca_names[dat$ccaa_iso]

dat %>% dplyr::filter(!is.infinite(rratio) & 
                        rratio < 50 &
                        fecha > min_date & 
                        !ccaa_iso %in% ca_ex) %>% 
  ggplot( aes(y = rratio, color = ccaa_iso, x = fecha)) +
  geom_line() +
  theme_classic() +
  facet_wrap(~label) +
  geom_hline(yintercept = 1) +
  scale_y_log10(expand = expansion())

dat_filt = dat %>% dplyr::filter(!is.infinite(rratio) &
                                   rratio < 50 & 
                                   fecha > min_date & 
                                   !ccaa_iso %in% ca_ex) 

dat_filt$fecha %>% unique() -> ufecha

ufecha = ufecha[20:length(ufecha)]

library(progress)
pb <- progress_bar$new(total = length(ufecha),
                       format = ":percent [:bar] eta: :eta | elapsed: :elapsed",
                       clear = FALSE,
                       width= cli::console_width())

ufecha %>% purrr::map(function(x){
  # this goes inside the iteration
  pb$tick()
  dat_filt %>% dplyr::filter(fecha < x) %>% 
    ggplot( aes(y = rratio, color = ccaa_iso, x = total7mean)) +
    geom_point() +
    geom_path() +
    theme_classic() +
    facet_wrap(~label, scales = "free_x") +
    geom_hline(yintercept = 1) +
    scale_y_log10(expand = expansion()) +
    scale_x_continuous(expand = expansion()) +
    theme(legend.position = "none") ->main_plot
  fout = glue::glue("{x}_ia.png")
  ggsave(fout, width = 9, height = 7)
})

