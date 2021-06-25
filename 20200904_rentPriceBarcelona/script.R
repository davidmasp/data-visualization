
# imports -----------------------------------------------------------------

library(vroom)
library(ggplot2)
library(magrittr)

# data --------------------------------------------------------------------

dat_preu = vroom(file = fs::dir_ls("data/price/",
                                   glob ="*_lloguer_preu_trim.csv"))

dat_compra = vroom(file = fs::dir_ls("data/compra/",
                                   glob ="*_comp_vend_preu_trim.csv"))

dat_count = vroom(file = fs::dir_ls("data/count/",
                                   glob ="*_lloguer_cont_trim.csv"))

full_dat = dplyr::inner_join(dat_compra,dat_count) %>% 
  dplyr::inner_join(dat_preu)



# plot --------------------------------------------------------------------
dat_preu$Preu = as.numeric(dat_preu$Preu)
dat_preu = as.data.frame(dat_preu)
ifelse(grepl(x = dat_preu$Lloguer_mitja,
             pattern = "per superfície"),
       yes = "eurM2_lloguer",
       no = "eur_lloguer") -> dat_preu$Lloguer_mitja


ggplot(dat_preu, aes(x = factor(Any), y = Preu )) + 
  geom_boxplot() +
  facet_grid(Lloguer_mitja~Nom_Districte,scales = "free") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))


dat_count = as.data.frame(dat_count)
dat_count %<>% dplyr::filter(Nom_Districte != "No consta")
ggplot(dat_count, aes(x = factor(Any), y = Nombre )) + 
  geom_boxplot() +
  facet_grid(Contractes~Nom_Districte,scales = "free") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))



dat_compra = as.data.frame(dat_compra)
dat_compra$Valor = as.numeric(dat_compra$Valor)

dat_compra %>% dplyr::filter(
  grepl(pattern = "Total",x = Preu_mitja_habitatge)
) %>% 
  dplyr::mutate(
    tipus = ifelse(grepl("m2",Preu_mitja_habitatge),
                   yes = "eurM2_compra",
                   no = "eur_compra")
  ) -> dat_compra

ggplot(dat_compra, aes(x = factor(Any), y = Valor )) + 
  geom_boxplot() +
  facet_grid(tipus~Nom_Districte,scales = "free") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))





