



# imports -----------------------------------------------------------------

library(magrittr)
library(xml2)
library(ggplot2)
library(patchwork)
source("utils.R")

# params ------------------------------------------------------------------

params <- jsonlite::read_json("params.json")

# data --------------------------------------------------------------------


params$instances %>% 
  purrr::map(function(instance){
    ## read null values 
    null_df = readRDS(instance$nullFN)
    null_df$type2 = "null"
    
    ## extract colors
    params$instances$euFootball$wikiFN %>% purrr::map("color") %>% unlist -> col
    ncols = names(col)
    col = c(col, "gray")
    names(col) = c(ncols,unique(null_df$type))
    
    instance$wikiFN %>% purrr::map2_df(names(.), function(wikiInstance,name_ty){
      extract_data_workflow(fn = wikiInstance$fn,type = name_ty)
    }) -> res_df
    
    res_df$type2 = "obs"
    #browser()
    final_dat = rbind(res_df,null_df)
    
    final_dat %>% dplyr::filter(type2 == "obs") %>% 
      dplyr::mutate(
      year_lab = ifelse(test = month > 6.5, "late","early")
    ) %>% 
      dplyr::group_by(type2,year_lab) %>% 
      dplyr::summarise(
        n_people = sum(n)
      ) %>% dplyr::group_by(type2) %>% 
      dplyr::mutate(
        total_cat = sum(n_people),
        perc_global = scales::percent(n_people / total_cat),
        position_x = ifelse(year_lab == "early", 5, 8)
      ) -> perc_labels
    
    final_dat %>% dplyr::group_by(month,type2) %>% 
      dplyr::summarise(total_n = sum(n)) -> grp_values
    
    1:12 %>% purrr::map_df(function(x){
      tmp_sjdh = grp_values
      tmp_sjdh$isMonth = tmp_sjdh$month == x
      dplyr::group_by(tmp_sjdh,isMonth,type2) %>% 
        dplyr::summarise(
          cont = sum(total_n)
        ) %>% 
        tidyr::pivot_wider(names_from = type2, values_from = cont) %>% 
        .[,2:3] %>% 
        as.matrix() %>%
        fisher.test() %>% 
        broom::tidy() -> test_df
      
      test_df$month = x
      test_df
    }) -> oddsRtio
    
    
    ggplot(final_dat,aes(x = month,
                         y = perc,
                         color = type,
                         linetype = type2)) +
      annotate(geom = "rect",
               xmin = 6.5,
               xmax = Inf,
               ymin = -Inf,
               ymax = Inf,
               fill = "gray94") +
      #geom_point() +
      geom_smooth(se = FALSE, span = 1) +
      geom_vline(xintercept = 6.5, linetype = "dotted") +
      geom_text(data = perc_labels,
                               inherit.aes = FALSE,
                               size = 5,
                               aes(x = position_x, 
                                   label = perc_global,
                                   y = quantile(final_dat$perc,.97))) +
      #geom_line() +
      scale_x_continuous(breaks = 1:12,
                         labels = month.abb) +
      scale_y_continuous(labels = scales::percent) +
      scale_linetype_manual(values = c(null = "dashed",
                                       obs = "solid")) +
      scale_color_manual(values = col) +
      theme_classic() +
      guides(linetype = FALSE) +
      labs(
        y = "Percentage of players born in each month",
        x = "",
        color = ""
      ) + theme(
        legend.position = "top",
        axis.ticks = element_blank(),
        axis.line = element_blank()
      ) -> plot_a
    
    ggplot(oddsRtio,aes(x = month, y = 1, fill = estimate))+
      geom_tile(color = "white", size = 3) +
      scale_fill_viridis_c(direction = -1,end = .82) +
      geom_text(aes(label = round(estimate,2), y = 1), color = "white") +
      scale_x_continuous(breaks = 1:12,
                         expand = expansion(),
                         labels = month.abb) +
      theme_void() +
      #coord_fixed() +
      theme(
        legend.position = "none",
        axis.ticks = element_blank(),
        axis.line = element_blank()
      ) -> plot_low
    
    
    (plot_a / plot_low) + plot_layout(heights = c(5,1)) -> fp
    
    
  }) -> list_of_plots


list_of_plots %>% purrr::map2(names(.), function(x,name){
  #browser()
  ggsave(x,filename = glue::glue("{name}.pdf"), width = 7, height = 5)
})

