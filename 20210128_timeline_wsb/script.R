


# imports -----------------------------------------------------------------

library(magrittr)
library(ggplot2)


annotations <- data.frame(
  Time = as.Date("2021-01-26 21:08:00 UTC"),
  label = "Elon Mush Tweet"
)


dat = vroom::vroom("multiTimeline.csv", skip = 1)

dat[[3]] = ifelse(dat[[3]] == "<1", 0, as.numeric(dat[[3]]))

dat %>% tidyr::pivot_longer(cols = c(2,3,4),
                            names_to = "website",
                            values_to = "Interest") -> plot_data

plot_data %>% dplyr::group_by(website) %>% 
  dplyr::summarise(
    spline_interest = spline(x = Time, y = Interest)
  )

plot_data$website= gsub(x = plot_data$website,
                        pattern = ": \\(United States\\)",replacement = "")
color_palete = c("Twitter" = "#1f78b4",
                 "Reddit" = "#ff7f00",
                 "r/WallStreetBets" = "#6a3d9a")

plot_data$website= forcats::fct_relevel(plot_data$website,names(color_palete))

plot_data %>% ggplot(aes(x = Time, y = Interest, color = website)) +
  geom_line(size = 1) +
  geom_smooth(se = FALSE, linetype = "dashed", size = 1) + 
  theme_classic() +
  theme(axis.line.x = element_blank(),
        legend.position = "top",
        axis.text.x = element_text(size = 12)) +
  labs(color = "", x = "") +
  scale_color_manual(values = color_palete)

ggsave("figure.pdf",width = 5, height = 3)
