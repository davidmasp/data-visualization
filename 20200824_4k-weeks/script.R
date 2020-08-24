
# 4k weeks

# params ------------------------------------------------------------------

birthday = "1993-12-17"

events = list(
  "High School" = list(start =  "2005-09-07" ,
                       end = "2011-06-22"),
  univeristy = list(start = "2011-09-01",
             end = "2017-06-22"),
  PhD = list(start = "2017-08-01",
             end = "2022-03-01"),
  retirement = list(
    start = "2058-12-17",
    end = "2200-01-01")
)

color_scale = RColorBrewer::brewer.pal(n = length(events),name = "Set1")
names(color_scale) = names(events)

color_scale = c(color_scale,"none" = "black")

total_year = 80


# imports -----------------------------------------------------------------

library(lubridate)
library(ggplot2)

# script ------------------------------------------------------------------

year(birthday)
week(birthday)

# I think number of weeks should be constant
last_week = week("2020-12-31")
first_week =  week("2020-01-01")

total_weeks = total_year * last_week

expand.grid(year = year(birthday):(year(birthday) + total_year),
            week = first_week:last_week) -> plot_data

today_week = week(today())
today_year = year(today())


library(dplyr)


case_when(
  plot_data$year > today_year ~ "future",
  plot_data$week > today_week & plot_data$year == today_year ~ "future",
  TRUE ~ "past"
) -> plot_data$today



plot_data$decade = factor(plot_data$year %/% 10)

plot_data$decade = forcats::fct_relevel(plot_data$decade,
                                        levels = rev(levels(plot_data$decade)))



plot_data$event = "none"

for (i in names(events)){
  
  m1 = plot_data$year > year(events[[i]]$start)
  m2 = plot_data$year < year(events[[i]]$end)
  m3 = plot_data$week < week(events[[i]]$end)
  m4 = plot_data$week > week(events[[i]]$start)
  m5 = plot_data$year == year(events[[i]]$start)
  m6 = plot_data$year == year(events[[i]]$end)
  #browser()
  case_when(
    m1 & m2  ~ i,
    (m3 & m6) | (m4 & m5)  ~ i,
    TRUE ~ plot_data$event
  ) -> plot_data$event
  
}

ggplot(plot_data,aes(x = week, y = year)) + 
  geom_point(aes(shape = today,
                 color = event),
             size = 1.5) +
  theme_classic() +
  facet_grid(decade~., scale = "free_y",space = "free_y") + 
  scale_shape_manual(values = c(0,15)) +
  scale_color_manual(values = color_scale) + 
  theme(
    panel.spacing = unit(.2,"in"),
    plot.background = element_blank(),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    strip.background = element_blank(),
    strip.text = element_blank()
  )


ggsave(height = 12,width = 7,filename = "figure.pdf")


