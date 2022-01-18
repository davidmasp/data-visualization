
ca_names <- c(
  "AN"  = 'Andalucía',
  "AR" = 'Aragón',
  "AS"  = 'Asturias',
  "CN"=  'Canarias',
  "CB"  = 'Cantabria',
  "CM" = 'Castilla-La Mancha',
  "CL"  = 'Castilla y León',
  "CT" = 'Catalunya',
  "EX"  = 'Extremadura',
  "GA" = 'Galicia',
  "IB"  = 'Illes Balears',
  "RI"= 'La Rioja',
  "MD"  = 'Madrid',
  "MC" = 'Murcia',
  "NC"  = 'Navarra',
  "PV"= 'País Vasco',
  "VC"  = 'Comunitat Valenciana'
)


roll_ratio <- function(x, k) {
  ## this is equivalent to this x[4] / x[1]
  ## if k = 3
  x / dplyr::lag(x,n = k)
}

