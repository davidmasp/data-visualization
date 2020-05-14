library(strava)
library(zoo)
library(tidyverse)
library(cowplot)
library(ggrepel)

data = process_data("data")
data$velocity = data$dist_to_prev / data$time_diff_to_prev
data$pace =  (data$time_diff_to_prev/60) / data$dist_to_prev
data$pace_m = rollapplyr(data$pace,
                         200,
                         mean,
                         partial=TRUE)

data$ele_to_prev = data$ele - dplyr::lag(data$ele)
data$ele_to_prev_m = rollapplyr(data$ele_to_prev,
                                10,
                                mean,
                                partial=TRUE)

ann_data = data.frame(
  ele = c(3718, 3275.1,3555),
  lon = c(-16.6458122,-16.6274089,-16.6388698),
  lat = c(28.2726106,28.2742037,28.2698486),
  cumdist = max(data$cumdist),
  label = c("Teide Summit",
            "Mountain hut",
            "Cable Car"))

p0 = ggplot(data,aes(x = cumdist,y = ele)) +
  geom_line(aes(color = pace_m)) +
  geom_point(data = ann_data,
             color = "gray70",
             shape = 3) +
  geom_vline(xintercept = max(data$cumdist),
             color = "gray70") +
  ggrepel::geom_text_repel(data = ann_data,
                           aes(label = label),
                           nudge_x      = -3,
                           direction    = "y",
                           segment.size = 0.2,
                           color = "gray70") +
  scale_y_continuous(labels = scales::unit_format(unit = "m")) +
  scale_x_continuous(labels = scales::unit_format(unit = "km"),
                     limits = c(1, max(data$cumdist))) +
  viridis::scale_color_viridis(option = "C") +
  labs(x = "Distance",
       y = "Elevation",
       color = "Pace (min/km)") +
  theme(plot.background = element_rect(fill = "gray30",color = NA),
        panel.grid.major = element_line(color = "gray70"),
        panel.background = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(linetype = "dashed"),
        text = element_text(color = "gray70"),
        legend.background = element_blank(),
        axis.text = element_text(color = "gray70"),
        axis.line = element_blank())

p1 = ggplot(data = data, aes(y = lat,
                        x = lon,
                        color = ele)) +
  geom_path() +
  viridis::scale_color_viridis(begin = 0.3) +
  geom_point(data = ann_data) +
  geom_text_repel(data = ann_data,
                           aes(label = label),
                           nudge_y = -0.005,
                           direction    = "y") +
  theme(plot.background = element_rect(fill = "gray30",color = NA),
        panel.grid.major = element_line(color = "gray70",
                                        linetype = "dashed"),
        panel.background = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        text = element_text(color = "gray70"),
        legend.background = element_blank(),
        axis.text = element_text(color = "gray70"),
        axis.line = element_blank()) +
  labs(x = "Longitude",
       y = "Latitude",
       color = "Elevation (m)")



fp = plot_grid(p0,p1,ncol = 1,align = "v")

ggsave(fp,filename = "teide_path_to_summit.pdf",width = 10,height = 10)
ggsave(fp,filename = "teide_path_to_summit.png",width = 10,height = 10)
