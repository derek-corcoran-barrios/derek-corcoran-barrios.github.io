library(raster)
library(rworldxtra)
library(sf)
library(tidyverse)

data("countriesHigh")

Mundo <- countriesHigh %>% 
  st_as_sf()


ggplot() + geom_sf(data = Mundo, aes(fill = POP_EST))

ggplot() + geom_sf(data = Mundo, aes(fill = REGION))


SA <- Mundo %>% dplyr::filter(continent == "South America and the Caribbean")

ggplot() + geom_sf(data = SA, aes(fill = POP_EST))

ggplot() + geom_sf(data = Mundo) + 
  geom_sf(data= SA, fill = "red") +
  theme_bw()


SA <- SA %>% 
  mutate(Pob_mill = POP_EST/1000000, PIB_per_cap = GDP_MD_EST/POP_EST)


ggplot() + geom_sf(data = SA, aes(fill = Pob_mill)) +
  theme_bw() +
  scale_fill_viridis_c(name = "Poblacion en millones") +
  theme(legend.position = "bottom")

ggplot() + geom_sf(data = SA, aes(fill = PIB_per_cap)) +
  scale_fill_viridis_c(name = "PIB") +
  theme_bw()

## Exportar el shapefile

SA <- SA %>% dplyr::select(PIB_per_cap, Pob_mill, ADMIN.1, SOVEREIGNT,GLOCAF)

write_sf(SA, "SA.shp")

### Leer un shapefile

SA2 <- read_sf("SA.shp")


ggplot() + geom_sf(data = SA2, aes(fill = GLOCAF)) +
  theme_light()


