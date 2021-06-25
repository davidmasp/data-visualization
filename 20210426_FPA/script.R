


# https://www.kaggle.com/rtatman/188-million-us-wildfires
library(magrittr)
library(ggplot2)
library(sf)
library(emojifont)
library(ggimage)
library(USAboundaries)
library(ggridges)


# data gather -------------------------------------------------------------

fn = "data/FPA_FOD_20170508.sqlite"

library(DBI)
con <- dbConnect(RSQLite::SQLite(), fn)
# dbListTables(con)
## this query selects all the needed columns columns in the table.
res <- dbSendQuery(con, "SELECT STAT_CAUSE_DESCR, STATE,LATITUDE,DISCOVERY_DOY FROM Fires")
dbFetch(res) -> dat
#dbDisconnect(con)

states_contemporary <- us_states()
states_contemporary %<>% dplyr::filter(! name %in% c("Puerto Rico",
                                                     "Alaska",
                                                     "Hawaii") )

# data wrangle ------------------------------------------------------------

selected = c("Fireworks","Smoking","Campfire","Arson","Lightning","Debris Burning")
dat %<>% dplyr::filter(STAT_CAUSE_DESCR %in% selected & STATE != "AL" )
dat %<>%dplyr::filter(LATITUDE < 50)

dat$STAT_CAUSE_DESCR = forcats::fct_relevel(
  dat$STAT_CAUSE_DESCR,
  selected
)

c("#7fc97f", "#beaed4", "#fdc086") -> colors
## the year 2004 doesn't actually matter, it could be anything.
## it is just used to unify the years.
date_0 = as.Date("2004-01-01")
las_day = as.Date("2004-12-30")
dat$date = dat$DISCOVERY_DOY + date_0

dat %>% dplyr::group_by(STAT_CAUSE_DESCR) %>%
  dplyr::summarise(
    total = dplyr::n(),
    median = median(DISCOVERY_DOY) + date_0
  ) -> med_df


colors = c(
  c("gray","#fbb4ae","gray"),
  c("gray","#b3cde3","gray"),
  c("gray","#ccebc5","gray"),
  c("gray","#decbe4","gray"),
  c("gray","#fed9a6","gray"),
  c("gray","#e5d8bd","gray")
)

colors2 = c(
  "#fbb4ae",
  "#b3cde3",
  "#ccebc5",
  "#decbe4",
  "#fed9a6",
  "#e5d8bd"
  )


# funs --------------------------------------------------------------------

### here I need to modify the quantile function to include the mode instead
moda <- function(v) {
  tmp <- unique(v)
  tmp[which.max(tabulate(match(v, tmp)))]
}

## need to return a numeric vector of 2 element
mode_fun <- function(x,probs) {
  #browser()
  stopifnot(length(probs) == 2)
  ## first element is left
  moda_value = moda(x)

  x_sorted = sort(x)
  moda_idx = x_sorted == moda_value
  moda_idx_med = round(median(which(moda_idx)))
  values_left = round(probs[1] * length(x))
  values_right = round(probs[1] * length(x))

  r_left = x_sorted[pmax(1,unique(moda_idx_med - values_left))]
  r_right = x_sorted[pmin(length(x),unique(moda_idx_med + values_right))]

  result = c(r_left, r_right)
  print(result)

  if (result[1]> result[2]){
    browser()
  }

  if (any(is.na(result))){
    browser()
  }

  if (length(result) != 2){
    browser()
  }


  names(result) = scales::percent(probs,accuracy = 1)

  return(result)

}


#plot distributions ------------------------------------------------------

dat %<>% dplyr::filter(!(is.na(date) | is.infinite(date))) %>%
  dplyr::filter(date < las_day)

ggplot(dat, aes(x = date,
                  y = STAT_CAUSE_DESCR,
                  fill = paste0(stat(y),factor(stat(quantile))))) +
  stat_density_ridges(geom = "density_ridges_gradient",
                      calc_ecdf = TRUE,
                      quantile_lines = TRUE,
                      bandwidth = 4,
                      scale = 4,
                      quantiles = c(.35,.35),
                      quantile_fun = mode_fun) +
  scale_fill_manual(values =colors) +
  scale_x_date(labels = scales::date_format("%B"),
               limits = c(date_0,las_day),
               breaks = seq(0,365,120) + date_0) +
  theme_classic() +
  theme(axis.line = element_blank(),
        axis.title = element_blank(),
        panel.grid.major.y = element_line(),
        axis.ticks = element_blank(), legend.position = "none")

ggsave("p1.pdf",width = 5,height = 10)


# map plots ---------------------------------------------------------------

dat %>% dplyr::group_by(STATE,STAT_CAUSE_DESCR) %>%
  dplyr::summarise(
    total = dplyr::n()
  ) -> values_df


states_contemporary <- us_states()

states_contemporary %<>% dplyr::filter(! name %in% c("Puerto Rico",
                                                     "Alaska",
                                                     "Hawaii"))

colors3 = c("#e41a1c",
            "#377eb8",
            "#4daf4a",
            "#984ea3",
            "#ff7f00",
            "#a65628")

names(colors3) = selected


values_df %>% split(.$STAT_CAUSE_DESCR) %>%
  purrr::map(function(x){
    #browser()
    color = colors3[unique(x$STAT_CAUSE_DESCR)]
    dplyr::left_join(states_contemporary,x,
                     by = c("stusps"= "STATE" )) -> map_data
    p <- ggplot(map_data) +
      geom_sf(color = "black", aes(fill = total))+
      coord_sf(xlim = c(-130, -70)) +
      scale_fill_gradient(low = "white",high = color) +
      theme_void() +
      theme(legend.position = "none") +
      labs(title = names(color))

    ggsave(p,filename = glue::glue("{names(color)}_map.pdf"),
           width = 2.5,
           height = 2.5)
  })


# percents for anotations -------------------------------------------------

dat$date %>% lubridate::week() -> dat$week
dat$date %>% lubridate::month() -> dat$month

dat %>% dplyr::group_by(STAT_CAUSE_DESCR) %>%
  dplyr::mutate(total = dplyr::n()) %>%
  dplyr::group_by(STAT_CAUSE_DESCR, week, month,total) %>%
  dplyr::tally() %>%
  dplyr::mutate(perc =scales::percent(n/total)) -> week_percent


dat %>% dplyr::group_by(STAT_CAUSE_DESCR) %>%
  dplyr::mutate(total = dplyr::n()) %>%
  dplyr::group_by(STAT_CAUSE_DESCR, month,total) %>%
  dplyr::tally() %>%
  dplyr::mutate(perc =scales::percent(n/total)) -> month_percent



