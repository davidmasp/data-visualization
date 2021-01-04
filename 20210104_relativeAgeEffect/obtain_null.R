
library(readr)
library(magrittr)
# obtain null -------------------------------------------------------------

url_1 = "https://raw.githubusercontent.com/fivethirtyeight/data/master/births/US_births_2000-2014_SSA.csv"

fs::dir_create("data/null")
curl::curl_download(url = url_1,
                    destfile = "data/null/us_births_2000-14_SSA.csv")
readr::cols(
  year = col_double(),
  month = col_double(),
  date_of_month = col_double(),
  day_of_week = col_double(),
  births = col_double()
) -> col_types
dat = readr::read_csv("data/null/us_births_2000-14_SSA.csv",
                      col_types = col_types)

total = sum(dat$births)
dat %>% dplyr::group_by(month) %>% 
  dplyr::summarise(n=sum(births),
                   perc = n / total) ->  plot_data_null_us


plot_data_null_us$type = "U.S. population"

saveRDS(plot_data_null_us,"null_us.rds")

# obtain null 2 -----------------------------------------------------------


mes <- c("Enero" = 1,
         "Febrero" = 2,
         "Marzo" = 3,
         "Abril" = 4, 
         "Mayo" = 5, 
         "Junio" = 6,
         "Julio" = 7 ,
         "Agosto" = 8,
         "Septiembre" = 9,
         "Octubre" = 10,
         "Noviembre" = 11,
         "Diciembre" = 12)

## this is a manual download from INE
fn = "data/null/spain_births_2019.tsv"

cols(
  Mes = col_character(),
  Total = col_character()
) -> ctypes

dat = readr::read_tsv(fn,col_types = ctypes)

dat$Total <- gsub(dat$Total,pattern = "[.]",replacement = "")
dat$Total <- as.numeric(dat$Total)

dat %<>% dplyr::filter(Mes != "Total") %>% dplyr::select(Mes, Total)

total = sum(dat$Total)
dat %>% dplyr::group_by(Mes) %>% 
  dplyr::summarise(n=sum(Total),
                   perc = n / total) ->  plot_data_null_es

plot_data_null_es$month = mes[as.character(plot_data_null_es$Mes)]

plot_data_null_es %<>% dplyr::select(month,n,perc) %>% 
  dplyr::arrange(month)

plot_data_null_es$type = "Spain population"

saveRDS(plot_data_null_es,"null_es.rds")


# plot --------------------------------------------------------------------

library(ggplot2)

all = rbind(plot_data_null_es,plot_data_null_us)

ggplot(all, aes(x = month, y = perc, color = type)) +
  geom_point() +
  geom_line()
