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

## Descargar datos vectoriales de Raster
## Descargar a niver region
Chile_Region  <- getData(name = "GADM", country = "CHL", level = 1)
Chile_SF_Region <- Chile %>% st_as_sf() %>% dplyr::filter(NAME_1 == "Los Ríos")
## Descargara a nivel comuna
Chile_CO <- getData(name = "GADM", country = "CHL", level = 3)
Chile_SF_CO <- Chile %>% st_as_sf() %>% dplyr::filter(NAME_1 == "Los Ríos")
## Transformar a SF



ggplot() + geom_sf(data = Chile_SF)

## Si quiero el código de un país

DF <- getData("ISO3")


### Descargar rasters

Prec <- getData(name = "worldclim", var = "prec", res = 10)

## Para graficar puedo hacer plot

plot(Prec)

## Para ver julio

plot(Prec[[7]])

plot(Prec[[c(12,1,2)]])

## para sumar

sum(Prec[[c(12,1,2)]]) %>% plot()

## Generar la capa

Pec_Verano1 <- Prec[[12]] + Prec[[1]] + Prec[[2]]

Pec_Verano2 <- sum(Prec[[c(12,1,2)]])


## Vemos prec a mediana resolicion

#Centroide los rios

LosRios <- st_centroid(Chile_SF_CO) %>% dplyr::filter(NAME_2 == "Valdivia")


Prec_LL <- getData(name = "worldclim", var = "prec", res = 0.5, lat = -39.87979, lon = -72.67173)
Prec_Total_LL <- sum(Prec_LL)

## Cortando un raster

Prec_Total_LL <- Prec_Total_LL %>% crop(Chile_SF_CO)
Prec_Total_LL <- Prec_Total_LL %>% mask(Chile_CO)

## Escribir un raster

writeRaster(Prec_Total_LL, "PrecLosLagos.tif") 


LL <- raster("PrecLosLagos.tif")

proj4string(LL)

LL2 <- LL %>%  projectRaster(crs = "+proj=aea +lon_0=-72.3339844 +lat_1=-44.3372695 +lat_2=-38.3711504 +lat_0=-41.3542099 +datum=WGS84 +units=m +no_defs")


Prec_LL2 <-Prec_LL %>% crop(LL)

LL_DF <- LL %>% as("SpatialPixelsDataFrame") %>% 
  as.data.frame()

ggplot() + geom_raster(data = LL_DF, aes(x = x, y = y, fill = PrecLosLagos)) +
geom_sf(data = Chile_SF_CO, alpha = 0)  +
  scale_fill_viridis_c() +
  labs(x = NULL,
       y = NULL)


List <- unstack(Prec_LL)

Stack <-  List %>% purrr::reduce(stack)
