

# kaggle datasets download -d phiitm/covid19-research-preprint-data
# unzip .\covid19-research-preprint-data.zip

# imports -----------------------------------------------------------------

library(magrittr)
library(ggplot2)
library(patchwork)

vroom::vroom("COVID-19-Preprint-Data.csv") -> dat

dat %<>% dplyr::filter(lubridate::year(dat$`Date of Upload`) >= 2020)
dat$week = dat$`Date of Upload` %>% lubridate::week()
dat$wy = glue::glue("{lubridate::year(dat$`Date of Upload`)}-{dat$week}")

dat %>% 
  dplyr::group_by(wy,`Uploaded Site`) %>% 
  dplyr::summarise(count = dplyr::n(),
                   wy_date = min(`Date of Upload`)) %>% 
  dplyr::ungroup() -> timeline_dat



timeline_dat %>% ggplot(aes(x = wy_date,
                   y = count,
                   color = `Uploaded Site`)) +
  geom_line(size = 2) +
  theme_classic() +
  scale_color_brewer(palette = "Set1") +
  scale_y_continuous(expand = expansion(0,0)) +
  labs(y = "Number of preprints",
       x = "Date (week)") +
  theme(legend.position = "none")-> p1

dat %>% ggplot(aes(x = 1,
                   fill = `Uploaded Site`,
                   y = `Number of Authors`)) +
  geom_violin() +
  scale_y_log10() +
  theme_minimal() +
  scale_fill_brewer(palette = "Set1") +
  theme(panel.grid = element_blank(),
        axis.line.y = element_line(linetype = "solid"),
        axis.text.x = element_blank(),
        axis.title.x = element_blank() )-> p2




dat %>% split(1:nrow(dat)) %>% 
  purrr::map_df(function(x){
    txt = x$`Author(s) Institutions`
    
    # prob clean this up
    tryCatch({
      gsub(x = txt, pattern = "'s",replacement = "") %>% 
        gsub(pattern = "' ",replacement = " ") %>% 
        gsub(pattern = "Xi'an", replacement = "Xian") %>% 
        gsub(pattern = "\\\'",
             replacement = "\\\"") %>%
          jsonlite::fromJSON() -> txt_list
      data.frame(
        n_authors = unlist(txt_list),
        institution = names(txt_list),
        preprint_server = unique(x$`Uploaded Site`)
      ) -> res
      
      res
    }, error = function(err){
      warning("parsing error")
      data.frame()
    })
    
  }) -> inst_df


inst_df %>%
  dplyr::group_by(institution,preprint_server) %>%
  dplyr::summarise(total_authors = sum(n_authors)) %>%
  dplyr::arrange(-total_authors) %>%
  dplyr::ungroup() %>%
  dplyr::group_by(preprint_server) %>%
  dplyr::top_n(10) -> inst_data

inst_data$institution = forcats::fct_reorder(.f = inst_data$institution,
                                             .x = inst_data$total_authors,
                                             .fun = sum)


inst_data$institution = forcats::fct_recode(inst_data$institution,
                    "Peking Union Medical College" = "Institute of Medical Biology, Chinese Academy of Medical Sciences and Peking Union Medical College")

inst_data %>% ggplot(aes(x = institution,
                         y = total_authors,
                         fill = preprint_server)) +
  geom_col() +
  scale_fill_brewer(palette = "Set1") +
  coord_flip()+
  scale_y_continuous(expand = expansion(0,0)) +
  theme_minimal() +
  labs(title = "Top10 institutions", y = "Number of authors") +
  theme(legend.position = "none",
        panel.grid = element_blank(),
        axis.text.y = element_text(size = 8),
        axis.title.y = element_blank()) -> p3

layout <- c(
    area(t = 1, l = 1, b = 5, r = 6),
    area(t = 1, l = 2, b = 2, r = 4),
    area(t = 1, l = 7, b = 5, r = 10)
  )
p1 + p2 +  p3 +
  plot_layout(design = layout) +
  plot_annotation(title = 'COVID-19 preprint submissions',
                  caption = '@davidmasp // data from kaggle:phiitm/covid19-research-preprint-data')

ggsave("plot.pdf",width = 10,height = 5)
