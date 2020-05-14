#!/usr/bin/env Rscript

# Name: book length vizz
# Author: DMP
# Description: Visualize the length of book series

# imports -----------------------------------------------------------------

library(ggplot2)
library(magrittr)
library(patchwork)

# funs --------------------------------------------------------------------

obtain_point_df <- function(total) {
  seq(from = 0, to = total) -> x

  x_val = substr(x,
                 start = nchar(x),
                 stop = nchar(x))
  y_val = substr(x,
                 start = 1,stop = nchar(x)-1)

  y_val = ifelse(y_val == "",yes = 0,no = y_val)

  dat2 = data.frame(
    x = x_val,
    y = y_val
  )
  dat2$x = as.numeric(as.character(dat2$x))
  dat2$y = as.numeric(as.character(dat2$y))
  return(dat2)
}

# params ------------------------------------------------------------------

params_title = "The Cosmere Series"
params_author = "Brandon Sanderson"
params_wpm = 250
params_words_per_point = 10000

base_url = "https://docs.google.com/spreadsheets/d"
sheet_id = "1vi3ZIA-aka0meB8rOLKByZWHnci1ow2kQ0eez35E_T4"
query = "export?format=csv"

# data --------------------------------------------------------------------

fs::dir_create("data")
url = glue::glue("{base_url}/{sheet_id}/{query}")
curl::curl_download(url, "data/data.csv")

# script ------------------------------------------------------------------

dat = vroom::vroom("data/data.csv")

# this assumes 250 WPM
dat$time = dat$Words / params_wpm


# wrangling ---------------------------------------------------------------

dat$series_cont = ifelse(is.na(dat$series_cont),0,dat$series_cont)

dat$Anthology_included = ifelse(dat$Anthology_included == "TRUE",
                                yes = "anthology-included",
                                no = "")


# repr -------------------------------------------------------------------
dat$Series = forcats::fct_reorder(dat$Series,.x = dat$Publication,min)
dat$Title = forcats::fct_reorder(dat$Title,.x = dat$series_cont,min)

dat = dat %>% dplyr::arrange(series_cont) %>%
  dplyr::group_by(Series) %>%
  dplyr::mutate(csum_words = cumsum(Words),
                csum_time = cumsum(time),
                last_time  = dplyr::lag(csum_time)) -> dat

series_table = table(dat$Series)
lones = names(series_table)[series_table== 1]

dat$Series_label = ifelse(dat$Series %in% lones,"Standalone",
                          as.character(dat$Series))
dat$Series_label = factor(dat$Series_label,
                          levels = c("Standalone",levels(dat$Series)))
dat$Series_label = droplevels(dat$Series_label)

dat$last_time = ifelse(is.na(dat$last_time),0,dat$last_time)
dat$Title = forcats::fct_reorder(dat$Title,.x = -dat$csum_time,min)

# plots -------------------------------------------------------------------

color_pal = c("#999999",
              "#e41a1c",
              "#377eb8",
              "#4daf4a",
              "#984ea3",
              "#ff7f00",
              "#a65628",
              "#f781bf")

n_lvl = nlevels(dat$Series_label)

if (n_lvl>length(color_pal)) {
  color_pal = colorRampPalette(color_pal)(n_lvl)
}

dat %>% ggplot(aes(y = Title,
                   xend = last_time / (60 ),
                   x = csum_time / (60 ),
                   yend = Title,
                   color = Series_label)) +
  geom_segment(size = 1) +
  geom_point(size = 3,aes(shape = Anthology_included)) +
  facet_grid(Series_label~.,scales = "free_y",space = "free") +
  scale_x_continuous(labels = scales::comma,
                     expand = expand_scale(mult = c(0,0.1),add = c(0.1,0.1))) +
  theme_minimal() +
  labs(x = "Hours", y = "", color = "") +
  scale_color_manual(values = color_pal) +
  scale_shape_manual(values = c(19,18)) +
  theme(axis.line.y = element_line(),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        legend.position = "none",
        strip.text = element_blank())  -> p1

dat %>% split(dat$Series_label) %>%
  purrr::map_df(function(x){
    total = sum(x$Words)
    total2 = round(total / params_words_per_point)

    points = obtain_point_df(total2)

    points$Series_label = unique(x$Series_label)
    return(points)
  }) -> points_df

points_df %>% ggplot(aes(x = x,y = y, color = Series_label)) +
  geom_point() +
  facet_grid(Series_label~.,space = "free",scales = "free",switch = "y") +
  scale_y_continuous(expand = expand_scale(mult = c(0,0),add = c(1,1))) +
  theme_minimal() +
  scale_color_manual(values = color_pal) +
  theme(panel.grid = element_blank(),panel.spacing = unit(0.1,"cm"),
        axis.text = element_blank(),
        axis.title = element_blank(),
        legend.position = "none",
        strip.text.y = element_text(angle = 180)) -> p2

# figure ------------------------------------------------------------------

caption_text = "
{params_wpm} WPM is used to transform words into time
Each dot represents {params_words_per_point} words
Diamonds represent books available in anthologies
"

p2 +
  p1 +
  patchwork::plot_layout(nrow = 1,widths = c(1,8))+
  plot_annotation(
    title = params_title,
    subtitle = glue::glue("Author: {params_author}"),
    caption = glue::glue(caption_text)
  ) -> final_fig

final_fig %>% print()

ggsave(plot = final_fig,
       filename = glue::glue("{params_title}_book_length.pdf"),
       width = 14,height = 6)

