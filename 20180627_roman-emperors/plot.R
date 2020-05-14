library(magrittr)
library(ggplot2)
library(extrafont)
loadfonts(device = "win",quiet = TRUE)
url = "https://raw.githubusercontent.com/zonination/emperors/master/emperors.csv"
dat = readr::read_csv(url)

dat$century = ceiling(lubridate::year(dat$reign.end)/100)

total = nrow(dat)
p1 = dat %>% dplyr::select(birth.prv,rise,cause,killer,dynasty,era,century) %>%
  tidyr::gather("var","val",-cause) %>%
  dplyr::group_by(cause,var,val) %>%
  dplyr::summarise(n = n()) %>%
  ggplot(aes(x = cause,val,fill = n)) +
  geom_tile(colour="gray20",size=1) +
  facet_grid(var~.,
             scales = "free",
             space = "free")+
  labs(x = "Cause of death",
       fill = "") +
  viridis::scale_fill_viridis(option = "A", direction = -1, begin = 0.2,
                              end = 0.9) +
  theme(axis.text.x = element_text(angle = 90),
        axis.text = element_text(color = "white",
                                 family = "Lato"),
        axis.title = element_text(color = "white",
                                  family = "Montserrat SemiBold"),
        axis.title.y = element_blank(),
        axis.ticks = element_blank(),
        axis.line = element_blank()) +
  theme(strip.background = element_rect(colour = NA, fill = NA),
        strip.text = element_text(color = "white",family = "Montserrat"),
        strip.placement = "outside") +
  theme(legend.background = element_rect(fill = NA),
        legend.box.background = element_rect(fill = NA,linetype = "blank"),
        legend.box.spacing = unit(1.5, "lines"),
        legend.title = element_text(color = "white"),
        legend.position = "bottom",
        legend.text = element_text(color = "white")) +
  theme(panel.border = element_rect(linetype = "blank", fill = NA,
                                    color = "white"),
        panel.background = element_blank(),
        panel.spacing = unit(1.5, "lines"),
        panel.grid = element_blank()) +
  theme(plot.background = element_rect(fill = "gray20",color = NA))





# obtain the length
dat$reign.start = as.numeric(dat$reign.start,"days") 
dat$reign.end = as.numeric(dat$reign.end,"days")
time0 = as.numeric(lubridate::date("0001-01-01"),"days")
dat$len = dat$reign.end - dat$reign.start
dat[1,"len"] = (dat[1,]$reign.end - time0) + (dat[1,]$reign.start - time0)

col_pallete  = c('#a6cee3',
                 '#1f78b4',
                 '#b2df8a',
                 '#33a02c',
                 '#fb9a99',
                 '#e31a1c',
                 '#fdbf6f')

p2 = ggplot(dat,aes(x = forcats::fct_reorder(name,.x = -index,.fun = mean),
               y=as.numeric(len),
               color = cause)) +
  geom_point(stat = "identity") +
  geom_segment(aes(x = name,xend = name, y = 0,yend = as.numeric(len))) +
  facet_grid(century~.,scales = "free",space = "free") + 
  coord_flip() + 
  labs(y = "Days in power*", color = "Cause of death") +
  scale_color_manual(values = col_pallete) +
  scale_y_sqrt(breaks = c(500,1000,1500,5000,10000,15000)) +
  theme(axis.text.x = element_text(angle = 90),
        axis.text = element_text(color = "white",
                                 family = "Lato"),
        axis.title = element_text(color = "white",
                                  family = "Montserrat SemiBold"),
        axis.title.y = element_blank(),
        axis.ticks = element_blank(),
        axis.line = element_blank()) +
  theme(strip.background = element_rect(colour = NA, fill = NA),
        strip.text = element_text(color = "white",family = "Montserrat"),
        strip.placement = "outside") +
  theme(legend.background = element_rect(fill = NA),
        legend.box.background = element_rect(fill = NA,linetype = "blank"),
        legend.box.spacing = unit(1.5, "lines"),
        legend.key = element_blank(),
        legend.position = "bottom",
        legend.title = element_text(color = "white",family =  "Montserrat"),
        legend.text = element_text(color = "white",family = "Lato")) +
  theme(panel.border = element_rect(linetype = "blank", 
                                    fill = NA,
                                    color = "white"),
        panel.background = element_blank(),
        panel.spacing = unit(1.5, "lines"),
        panel.grid = element_blank()) +
  theme(plot.background = element_rect(fill = "gray20",color = NA))

fp = cowplot::plot_grid(p1,p2,rel_widths = c(1,1.5))

# save plot

ggsave(plot = fp,filename = "plot.svg",device = "svg",width = 10,height = 11)
