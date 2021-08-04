

# impots ------------------------------------------------------------------

library(magrittr)
library(ggplot2)
library(readr)

# data --------------------------------------------------------------------

beforeIAAF = "01-01-1912"

cols(
  Time = col_double(),
  Athlete = col_character(),
  Nationality = col_character(),
  Location = col_character(),
  Date = col_date(format = "")
) -> col_types

dat = readr::read_csv("Sheet1.csv",col_types = col_types)

# script ------------------------------------------------------------------

ggplot(dat, aes(x = Date, y = Time)) +
  geom_point() +
  geom_line()



# script2 -----------------------------------------------------------------

pre_IAAF = "1990-01-01" %>% as.Date()

col_types = cols(
  Mark = col_character(),
  Athlete = col_character(),
  Date = col_date(format = ""),
  Location = col_character()
)
dat = readr::read_csv("data/women_triple_jump.csv", col_types = col_types)


dat$Mark_m = dat$Mark %>% stringr::str_extract("[:digit:]+\\.[:digit:]+") %>%
  as.numeric()
set.seed(42)
min_date = "1980-01-01" %>% as.Date()
dat %>%
  dplyr::filter(Date > min_date ) %>%
    ggplot( aes(x = Date, y = Mark_m)) +
  annotate(geom = "rect",
           xmin = min_date,
           fill = "gray90",
           xmax = pre_IAAF,
           ymin = -Inf,
           ymax = Inf) +
    geom_point() +
    geom_line() +
    geom_vline(xintercept = pre_IAAF, linetype = "dashed") +
    ggrepel::geom_text_repel(aes(label = Athlete)) +
    theme_classic() +
  theme(text = element_text(size = 10),
        axis.ticks = element_blank()) +
  scale_x_date(expand = expansion(mult = c(0,0), add = c(0,0))) +
  scale_y_continuous(labels = scales::unit_format(accuracy = 1)) +
  labs(y = "Distance", x = "Year")

ggsave("plot.pdf", width = 8, height = 4)


# script3 -----------------------------------------------------------------

pre_IAAF = "1976-01-01" %>% as.Date()

col_types = cols(
  Time = col_double(),
  Name = col_character(),
  Date = col_date(format = ""),
  ddd = col_character()
)
dat = readr::read_csv("data/men_400_hurdles.csv", col_types = col_types)

set.seed(42)
min_date = "1950-01-01" %>% as.Date()
dat %>%
  dplyr::filter(Date > min_date ) %>%
  ggplot( aes(x = Date, y = Time)) +
  annotate(geom = "rect",
           xmin = min_date,
           fill = "gray90",
           xmax = pre_IAAF,
           ymin = -Inf,
           ymax = Inf) +
  geom_point() +
  geom_line() +
  geom_vline(xintercept = pre_IAAF, linetype = "dashed") +
  ggrepel::geom_text_repel(aes(label = Name)) +
  theme_classic() +
  theme(text = element_text(size = 12),
        axis.ticks = element_blank()) +
  scale_x_date(expand = expansion(mult = c(0,0.05), add = c(5,5))) +
  scale_y_continuous(labels = scales::unit_format(accuracy = 1,suffix = "s")) +
  labs(y = "Time", x = "Year")

ggsave("plot2.pdf", width = 8, height = 4)

