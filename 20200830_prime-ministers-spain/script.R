


# imports -----------------------------------------------------------------

library(magrittr)
library(ggplot2)

# data --------------------------------------------------------------------

pm_tb = vroom::vroom("data/PM_office.csv")
mdata = vroom::vroom("data/Metadata.csv")
pop_dat = vroom::vroom("data/population.csv")

# script ------------------------------------------------------------------

pm_tb = dplyr::left_join(pm_tb,mdata)

pm_tb$birth_date = glue::glue("{pm_tb$Birth}-01-01") %>% as.Date()
death_date = glue::glue("{pm_tb$Death}-12-31") %>% as.Date()
death_date[is.na(death_date)] = as.Date(Sys.Date())
pm_tb$death_date = death_date

# plot --------------------------------------------------------------------

pm_tb$Name = factor(pm_tb$Name)
pm_tb$Name = forcats::fct_reorder(.f = pm_tb$Name,
                                  .x = pm_tb$Office_start,
                                  .fun = min,.desc = TRUE)

pm_mdata = pm_tb %>% dplyr::distinct(birth_date,death_date,Name)

ggplot(pm_tb,aes(x = Office_start,
                 xend = Office_ends, 
                 y = Name,
                 yend = Name,
                 color = Party)) +
  geom_segment(size = 1.5)+
  geom_segment(data = pm_mdata,
               inherit.aes = FALSE,
               aes(x = birth_date,
                   xend = death_date, 
                   y = Name,
                   yend = Name), color = "black") +
  theme_classic() +
  theme(axis.text.y = element_blank(),legend.position = "none")

pm_tb$duration = pm_tb$Office_ends - pm_tb$Office_start

pm_tb %>% dplyr::group_by(Born_in_current_state,
                          Born_in_current_country) %>% 
  dplyr::summarise(total_days = sum(duration)) -> days_in_office

days_in_office$Born_in_current_state = forcats::fct_reorder(days_in_office$Born_in_current_state,
                                                            .x =days_in_office$total_days,
                                                            .desc = TRUE)

ggplot(days_in_office,
       aes(x = Born_in_current_state,fill = Born_in_current_country,
           y = total_days)) +
  geom_col() + 
  scale_y_continuous(expand = expansion(0,0)) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90))

days_in_office %>% dplyr::inner_join(pop_dat) -> ccaa_dat

ccaa_dat$days_per_hab = as.numeric(ccaa_dat$total_days) / ccaa_dat$inhabitants

ccaa_dat$Born_in_current_state = forcats::fct_reorder(
  ccaa_dat$Born_in_current_state,
  ccaa_dat$days_per_hab,.desc = TRUE
)

ggplot(data = ccaa_dat,aes(x = Born_in_current_state,
                           y = days_per_hab )) +
  geom_point() +
  scale_y_log10() +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
  



pm_tb$age = pm_tb$Death - pm_tb$Birth  

pm_tb %>% ggplot(aes(x = pm_tb$Death, y = age, color = is_assassinated_in_office)) +
  geom_point() +
  geom_smooth(method = "lm")



min_decade = min(lubridate::year(pm_tb$Office_start)%/%10)
max_decade = max(lubridate::year(pm_tb$Office_ends)%/%10)

for (i in min_decade:max_decade){
  pre_date = as.Date(glue::glue("{i}0-01-01"))
  post_date = as.Date(glue::glue("{i}9-12-31"))
  
  vec_pre = pm_tb$Office_start > pre_date
  vec_post = pm_tb$Office_ends < post_date
  
  n = sum(vec_pre&vec_post)
  
  data.frame(
    decade = i,
    number_of_govt = n
  ) -> df
  print(df)
}

pm_tb$decade = lubridate::year(pm_tb$Office_start)%/%10

pm_tb %>% dplyr::group_by(decade) %>% 
  dplyr::summarise(mean_duration = mean(duration),
                   median_duration = median(duration)) %>% 
  ggplot(aes(x = decade,y = median_duration)) +
  geom_line()+
  geom_point()

