library(sf)
library(tidyverse)
library(rworldxtra)
data("countriesHigh")

Mundo <- st_as_sf(countriesHigh)

ggplot() + geom_sf(data = Mundo, aes(fill = REGION))


## Podemos subsetear

Africa <- Mundo %>% dplyr::filter(continent == "Africa")
ggplot() + geom_sf(data = Africa, aes(fill = POP_EST))

## Un subset por gdp

PIB_Alto <- Mundo %>% dplyr::filter(GDP_MD_EST >= median(Mundo$GDP_MD_EST))

ggplot() + geom_sf(data = PIB_Alto, aes(fill = GDP_MD_EST))


ggplot() + geom_sf(data = Mundo) + geom_sf(data = PIB_Alto, aes(fill = GDP_MD_EST)) + theme_dark() + scale_fill_viridis_c()

### MOdificar y generar otras bases de datos

Africa <- Africa %>% mutate(Poblacion_mill = POP_EST/1000000)

ggplot() + geom_sf(data = Africa, aes(fill = Poblacion_mill)) + scale_fill_viridis_c()



Africa <- Africa %>% mutate(PIB_per_Cap = GDP_MD_EST/POP_EST)

ggplot() + geom_sf(data = Africa, aes(fill = PIB_per_Cap)) + scale_fill_viridis_c()

### Seleccionar algunas columnas y exportar

Africa <- Africa %>% dplyr::select(NAME, Poblacion_mill, PIB_per_Cap, GLOCAF)

write_sf(Africa, "Africa.shp")

Africa2 <- read_sf("Africa.shp")
ggplot() + geom_sf(data= Africa2,aes(fill = GLOCAF))


### Datos vectoriales de R


Peru <- getData(name = "GADM", country = "PER", level = 2) %>% 
  st_as_sf()
ggplot() + geom_sf(data = Peru) + theme(legend.position = "none")

DF <- data.frame(lon = c(-76, -76), lat = c(-5, -4), Casa = c("Grande", "Chica")) %>% st_as_sf(coords = c(1,2), crs = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

ggplot() + geom_sf(data = Peru) + geom_sf(data = DF, aes(color = Casa)) 

Peru2 <- Peru %>% dplyr::filter(NAME_1 %in% c("Amazonas", "Arequipa", "Tacna"))

ggplot() + geom_sf(data = Peru2)


### Rasters

Prec <- getData("worldclim", res = 10, var = "prec")
Prec

Invierno <- Prec[[c(6, 7, 8)]]
plot(Invierno, colNA = "black")

rasterVis::levelplot(Invierno)

Total_inv <- Prec[[6]] + Prec[[7]] + Prec[[8]]
plot(Total_inv, colNA = "black")

PP_Total <- sum(Prec)
plot(PP_Total, colNA = "black")


### PAra cortar

Raster_Africa <- PP_Total %>% crop(Africa)

Raster_Peru <- PP_Total %>% crop(Peru) %>% mask(Peru)

DF$Prec <- extract(Raster_Peru, DF)

Prec_Casas <- extract(Prec, DF)

#Escribir raster

writeRaster(Raster_Africa, "PP_Africa.grd", overwrite = T)
Raster_Africa2 <- raster("PP_Africa.grd")

plot(Raster_Africa2)

### Proyecciones


Africa_igual <- projectRaster(Raster_Africa, crs = "+proj=laea +lon_0=23.2 +lat_0=-0.49 +datum=WGS84 +units=m +no_defs")
plot(Africa_igual, colNA = "black")
plot(Raster_Africa)


ggplot() + geom_sf(data = Peru2)


PrecPeru2 <- crop(PP_Total, Peru2) %>% mask(Peru2) 


## Grafico de shapefiles y rasters

Africa_DF <- Raster_Africa %>% as("SpatialPixelsDataFrame") %>% 
  as.data.frame() %>% rename(Prec = layer)


ggplot() + geom_tile(data = Africa_DF, aes(x = x, y = y, fill = Prec)) + geom_sf(data = Africa, alpha = 0) + scale_fill_viridis_c() + xlab("") + ylab("") + theme_bw()


ggplot() + geom_tile(data = Africa_DF, aes(x = x, y = y, fill = Prec)) + geom_sf(data = Africa, alpha = 0) + scale_fill_viridis_c() + xlab("") + ylab("") + theme_bw()+ coord_sf(crs = "+proj=laea +lon_0=18.28125 +lat_0=0 +datum=WGS84 +units=m +no_defs") 

