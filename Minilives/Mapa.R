library(sf)
library(tidyverse)
library(raster)
library(dismo)

View(getData("ISO3"))

Chile <- getData("GADM", country = "CHL", level = 3) %>% st_as_sf() %>%  dplyr::filter(NAME_1 %in% c("Coquimbo")) %>% rename(Provincia = "NAME_2")

Chile$Population <- rpois(15, 1000)

ggplot() + geom_sf(data = Chile, aes(fill = Population)) + geom_sf_text(data = Puntos, aes(label = Species)) + theme_bw()


Tmin <- getData("worldclim", var = "tmin", res = 2.5) %>% crop(extent(Chile))

TminEnero <- Tmin[[1]]

Puntos <- dismo::randomPoints(mask = TminEnero, n = 30) %>% as.data.frame() %>% st_as_sf(coords = c(1,2), crs = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

Puntos$Species <- sample(c("A","B"), 30, replace = T)
Puntos$Size <- rpois(30, 100)
