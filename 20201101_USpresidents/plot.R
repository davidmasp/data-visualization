


# import ------------------------------------------------------------------
 
library(magrittr)
library(ggplot2)
library(sf)
library(USAboundaries)
source("utils.R")

# data --------------------------------------------------------------------

dat = readRDS("data.rds")


# manual fixes ------------------------------------------------------------

# Rutherford B. Hayes
idx_tmp = which(dat$name == "Rutherford B. Hayes")
dat[idx_tmp,"state"] = "Ohio"

# the scrapping also missed the second term of Grover Cleveland
# too much work for changing that

add_df = data.frame(
  check = "officeholder",
  name = "Grover Cleveland",
  birth_date = as.Date("1837-03-18"),
  death_date = as.Date("1908-06-24"),
  term_start = as.Date("1885-03-04"),
  term_end = as.Date("1889-03-04"),
  state = "New Jersey",
  is_us_state = TRUE
)

dat = rbind(dat, add_df)

## this is for the hopwfully last president on the list.
idx = which(is.na(dat$term_end))
stopifnot(length(idx) == 1)
dat[idx,"term_end"] =  Sys.Date()

# I do the same for the alive presidents
idx = which(is.na(dat$death_date))
dat[idx,"death_date"] =  Sys.Date()

dat$name = forcats::fct_reorder(dat$name,.desc = TRUE,dat$term_start)


dat = dplyr::left_join(dat,usReg)

dat$duration = dat$term_end - dat$term_start
dat %>% dplyr::group_by(state) %>% 
  dplyr::summarise(duration_total = sum(duration)) -> states_terms


states_terms_vec = states_terms$duration_total
names(states_terms_vec) = states_terms$state

ggplot(dat,aes(x = term_start,
                 xend = term_end, 
                 y = name,
                 yend = name,
                 color = region)) +
  geom_segment(size = 1.5) +
  geom_segment(data = dat,
               inherit.aes = FALSE,
               aes(x = birth_date,
                   xend = death_date, 
                   y = name,
                   yend = name, color = region)) +
  geom_text(aes(label = name,y = name, x = birth_date-500, hjust = 1),
            size = 8/ggplot2::.pt) +
  scale_x_date(expand = ggplot2::expansion(.25,0),position = "top") +
  scale_color_brewer(palette = "Set1") +
  theme_void() +
  theme(axis.text.x = element_text(face = "bold")) 

ggsave(filename = "timeline.pdf",width = 11,height = 8)

states_contemporary <- us_states()

state_durations = double(length(states_contemporary$name) )
names(state_durations) = states_contemporary$name
mask = names(state_durations) %in% names(states_terms_vec)
state_durations[mask] = states_terms_vec[names(state_durations[mask])]
state_durations[!mask] = NA
states_contemporary$duration_years = state_durations / 360

states_contemporary %<>% dplyr::filter(! name %in% c("Alaska","Puerto Rico") )

ggplot(states_contemporary) +
  geom_sf(aes(fill = duration_years),color = "#2b2b2b", size=0.125)+
  coord_sf() +
  scale_fill_viridis_c(option = "D",
                       direction = -1,
                       na.value = "gray90") +
  theme_void() +
  labs(fill = "Years in office")

ggsave(filename = "map.pdf",width = 8,height = 5)




dat$life = dat$death_date - dat$birth_date
dat %>% dplyr::summarise(
  presidentialStart_mean_age = mean(term_start - birth_date)/365,
  presidentialEnd_mean_age =  mean(term_end - birth_date,na.rm = T)/365,
  presidential_death_age = mean(death_date - birth_date,na.rm = T)/365
)


