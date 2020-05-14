#!/usr/bin/R

# import ------------------------------------------------------------------

library(magrittr)
library(ggplot2)
library(rtweet)

# params ------------------------------------------------------------------

tw_usr = c("progressbar201x",
           "year_progress")

# data --------------------------------------------------------------------

dat = purrr::map_df(tw_usr,
                    get_timeline,
                    n = 110)
dat$year = format(dat$created_at,"%Y")
dat %<>% dplyr::filter(year == 2019)
dat$time = lubridate::date(dat$created_at)

# plot --------------------------------------------------------------------

dat$text %>%
  stringr::str_extract(pattern = "[:digit:]+(?=%)") %>%
  as.numeric() -> dat$perc

dat$perc = dat$perc/100

# I think it makes no sense tbh, also technical, it
# overlapts in time with the 0%
dat %<>% dplyr::filter(perc != 1)

dat_lab = dat %>% dplyr::group_by(screen_name) %>% 
  dplyr::top_n(5,retweet_count) %>% 
  dplyr::mutate(val_max = max(retweet_count))

dat$created_at %<>% as.Date()


ggplot(dat,aes(x = time,y = retweet_count)) +
  geom_bar(width = 3.7,stat = "identity") +
  facet_wrap(~glue::glue("@{screen_name}"),
             scales = "free",
             ncol = 1) +
  ggrepel::geom_text_repel(
    data = dat_lab,
    aes(label = scales::percent(perc)),
    nudge_y       = dat_lab$retweet_count * 0.1 ,
    segment.colour = "gray70",
    direction     = "x") +
  scale_y_continuous(labels = scales::comma,
                     expand = expand_scale(mult = c(0,0.12))) +
  scale_x_date(expand = c(0,0)) +
  theme_classic() +
  theme(axis.line.y = element_blank(),
        axis.line.x = element_blank(),
        axis.ticks = element_blank(),
        strip.background = element_blank()) +
  labs(x = "",y = "Retweet Count")

