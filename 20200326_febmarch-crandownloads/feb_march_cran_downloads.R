

# imports -----------------------------------------------------------------
library(magrittr)
library(ggplot2)
library(cranlogs)


# params ------------------------------------------------------------------
list_of_packages = c("ggplot2", "devtools","fs")
time_from = "2020-02-01"
time_to = Sys.Date()

# data --------------------------------------------------------------------

dat = cran_downloads(from = time_from, to = time_to,
                     packages = list_of_packages)

datR = cran_downloads("R",from = time_from, to = time_to)

datR %>%
  dplyr::filter(!is.na(os) & os != "NA") %>% 
  dplyr::group_by(os,date) %>% 
  dplyr::summarise(total_count = sum(count)) -> datR


# plot --------------------------------------------------------------------

ggplot(dat,
       aes(x = date, y = count, fill = package)) +
  geom_col(width = 1) +
  scale_y_continuous(labels = scales::comma,expand = expansion(mult = c(0,0.1))) +
  facet_wrap(~package,scales = "free", nrow = 1) +
  theme_classic() +
  scale_fill_brewer(palette = "Set1") +
  labs(y = "package downloads") +
  theme(legend.position = "none",
        axis.title.x = element_blank(),
        axis.ticks.x = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(size = 12,face = "bold"))

ggplot(datR,
       aes(x = date, y = total_count, fill = os)) +
  geom_col(width = 1) +
  scale_y_continuous(labels = scales::comma,expand = expansion(mult = c(0,0.1))) +
  facet_wrap(~os,scales = "free", nrow = 1) +
  theme_classic() +
  scale_fill_brewer(palette = "Set1") +
  labs(y = "R downloads") +
  theme(legend.position = "none",
        axis.title.x = element_blank(),
        axis.ticks.x = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(size = 12,face = "bold"))



# sinfo -------------------------------------------------------------------

sessionInfo()
