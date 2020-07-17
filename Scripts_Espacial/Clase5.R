library(ggforce)
library(scales)
library(raster)
library(rworldxtra)
library(sf)
library(tidyverse)

setwd("~/derek-corcoran-barrios.github.io/Scripts_Espacial")

# Base de datos
githubURL <- ("https://raw.githubusercontent.com/derek-corcoran-barrios/derek-corcoran-barrios.github.io/master/Presentaciones_Espacial/Casos_Activos_Valpo.rds")
# La descargamos
download.file(githubURL, "Casos_Activos_Valpo.rds")
# La leemos
Casos_Activos_Valpo <- readRDS("Casos_Activos_Valpo.rds")
# Gráfico simple
ggplot() + geom_sf(data = Casos_Activos_Valpo, aes(fill = Activos_por_100.000)) + 
  facet_wrap(~Fecha)