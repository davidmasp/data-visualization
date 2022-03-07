#!/usr/bin/env Rscript

# Name: plotMiFit.R
# Author: DMP
# Description: 

# imports -----------------------------------------------------------------

library(magrittr)
library(ggplot2)
library(vroom)

# params ------------------------------------------------------------------

fn = "data/SLEEP/SLEEP_1644643023012.csv"

# data --------------------------------------------------------------------

dat = vroom(fn)

dat = dat %>% dplyr::filter(
  date > lubridate::date("2021-11-01")
)

# script ------------------------------------------------------------------

dat$timestart_hour = dat$start %>% lubridate::as_datetime() %>%  lubridate::hour()
dat$timeend_hour = dat$stop %>% lubridate::as_datetime() %>%  lubridate::hour()

dat$timestart_decimalminute = dat$start %>% 
  lubridate::as_datetime() %>%
  lubridate::minute() %>%
  magrittr::divide_by(60)
dat$timeend_decimalminute = dat$stop %>% 
  lubridate::as_datetime() %>% 
  lubridate::minute() %>% 
  magrittr::divide_by(60)

# time start decimal
dat$tsd = with(dat, timestart_hour + timestart_decimalminute)
dat$ted = with(dat, timeend_hour + timeend_decimalminute)

ch_date = lubridate::date("2022-01-02")

dat$tsd = ifelse(dat$start> ch_date, dat$tsd - 9, dat$tsd  )
dat$ted = ifelse(dat$start> ch_date, dat$ted - 9, dat$ted  )

ifelse(dat$tsd > dat$ted, dat$tsd - 24, dat$tsd) -> dat$tsd

dat = dat[dat$deepSleepTime != 0,]


avg_std = mean(dat[dat$date <= ch_date, ]$tsd)
avg_sed = mean(dat[dat$date <= ch_date, ]$ted)

colors = c("#ff7f00", "#1f78b4")
shade = c("#9e9ac8","#74c476")

ggplot(dat, aes(fill = date > ch_date,xmin = date-0.25, xmax = date+0.25,  ymin = tsd, ymax = ted)) +
  geom_vline(xintercept = ch_date, size = 1, linetype = "dashed") +
  geom_rect() +
  scale_y_continuous(breaks = seq(-2,10,1)) +
  geom_smooth(aes(x = date, y = tsd, group = date > ch_date), size = 2,span = 0.4, se = FALSE,  color = colors[1]) +
  geom_smooth(aes(x = date, y = ted, group = date > ch_date), size = 2, span = 0.4,se = FALSE, color = colors[2]) +
  geom_hline(yintercept = avg_std, color = colors[1], size = 1, linetype = "dashed") +
  geom_hline(yintercept = avg_sed, color = colors[2], size = 1, linetype = "dashed")+
  scale_x_date(expand = expansion()) +
  labs(y = "Sleeping time", x = "Date") +
  scale_fill_manual(values = shade) +
  theme_classic() +
  theme(legend.position = "none")

ggsave("plot.pdf", width = 6, height = 4)

ggplot(dat, aes(xmin = date-0.25, xmax = date+0.25,  ymin = tsd, ymax = ted)) +
  annotate(geom = "rect", 
           fill = shade[1],
           xmax = ch_date,
           xmin = min(dat$date)-1,
           alpha = 0.5,
           ymin = -Inf, 
           ymax = Inf) +
  annotate(geom = "rect", fill = shade[2],
           alpha = 0.5,xmax = max(dat$date)+1, xmin = ch_date,ymin = -Inf, ymax = Inf) +
  geom_vline(xintercept = ch_date, size = 1, linetype = "dashed") +
  geom_rect() +
  scale_y_continuous(breaks = seq(-2,10,1)) +
  geom_smooth(aes(x = date, y = tsd, group = date > ch_date), size = 2,span = 0.4, se = FALSE,  color = colors[1]) +
  geom_smooth(aes(x = date, y = ted, group = date > ch_date), size = 2, span = 0.4,se = FALSE, color = colors[2]) +
  geom_hline(yintercept = avg_std, color = colors[1], size = 1, linetype = "dashed") +
  geom_hline(yintercept = avg_sed, color = colors[2], size = 1, linetype = "dashed")+
  scale_x_date(expand = expansion()) +
  labs(y = "Sleeping time", x = "Date") +
  scale_fill_manual(values = shade) +
  theme_classic() +
  theme(legend.position = "none")

ggsave("plot2.pdf", width = 6, height = 4)


