library(ggforce)
library(ggrepel)
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


## Cambiar la escala

ggplot() + geom_sf(data = Casos_Activos_Valpo, aes(fill = Activos_por_100.000)) + 
  facet_wrap(~Fecha) + scale_fill_gradientn(name = "Activos por 100.000 hab", 
                                            colours = heat.colors(30))

## Gradient2


Mapa <- ggplot() + geom_sf(data = Casos_Activos_Valpo, size = 0.05, aes(fill = Activos_por_100.000)) + 
  facet_wrap(~Fecha) + 
  scale_fill_gradient2(name = "Activos por cada 100.000 hab.",
                       mid = "white", 
                       high = muted("red"),
                       low = muted("blue"),
                       midpoint = 40) +
  labs(title = "Prevalencia de COVID19 en Valparaíso",
       subtitle = paste("Actualizado en", max(Casos_Activos_Valpo$Fecha)),
       caption = "Datos: https://github.com/MinCiencia/Datos-COVID19",
       y = NULL, 
       x = NULL) +
  theme(legend.position = "bottom")

## Puntos

download.file("https://www.bcn.cl/obtienearchivo?id=repositorio/10221/10400/2/Toponimos.zip", 
              destfile = "Topo.zip")


unzip("Topo.zip")

Topo <- read_sf("Toponimos.shp") %>% 
  dplyr::filter(Region =="DE VALPARAISO") %>% 
  st_crop(Casos_Activos_Valpo)

Topo2 <- Topo %>% dplyr::filter(Clase_Topo == "Centro Poblado")

### Filtro a solo capitales provinciales

Topo2 <- Topo %>% dplyr::filter(Nombre %in% c("Los Andes", "Quilpué", 
                                              "La Ligua", "Quillota", "San Antonio", "San Felipe", "Valparaíso"), 
                                Clase_Topo %in% c("Centro Poblado"))


## Opción 1 label

Mapa + geom_sf(data = Topo2) + 
  geom_label_repel(data = Topo2, 
                  aes(label = Nombre, 
                      geometry = geometry), 
                  stat = "sf_coordinates", 
                  force = 1)

## Opción 2 text

Mapa + geom_sf(data = Topo2) + 
  geom_text_repel(data = Topo2, 
                  aes(label = Nombre, 
                      geometry = geometry), 
                  stat = "sf_coordinates", 
                  force = 1)


### Para exportar

tiff("Mapa.tiff", units = "in", width = 10, height = 5, res = 600, 
     compression = "lzw")

Mapa + geom_sf(data = Topo2) + 
  geom_text_repel(data = Topo2, 
                  aes(label = Nombre, 
                      geometry = geometry), 
                  stat = "sf_coordinates", 
                  force = 1)

dev.off()


### Rasters

download.file("https://ndownloader.figshare.com/files/21843771", 
              destfile = "Priority.tiff")
Priority <- raster("Priority.tiff")

library(rgdal)

Priority <- readGDAL("Priority.tiff")
Priority <- raster("/home/derek/Downloads/NT_Plants_Verts_SSI_rcp85_mean.tif")

## Agregamos un shapefile

data("countriesHigh")
SA <- countriesHigh %>% st_as_sf() %>% st_make_valid() %>% st_crop(extent(Priority))
ggplot() + geom_sf(data = SA)


## Transformar mi raster 

## Agregar 0 en vez de NA

values(Priority) <- ifelse(is.na(values(Priority)), 0, values(Priority))

## Crear una mascara

MASK <- rasterize(SA, Priority, field = 1)

Priority <- MASK*Priority

Priority <- trim(Priority)

Priority2 <- Priority %>% as("SpatialPixelsDataFrame") %>% 
  as.data.frame() %>% 
  rename(Priority = layer) %>% 
  mutate(Priority = case_when(Priority >= 0.97 ~ "Prioridad muy alta", 
                              Priority < 0.97 & Priority > 0.87 ~ "Prioridad alta", 
                              Priority == 0 ~ "Altamente desarrollado")) %>% 
  dplyr::filter(!is.na(Priority)) %>% 
  mutate(Priority = fct_relevel(Priority, "Prioridad muy alta", "Prioridad alta"))


## Graficar primero

P <- ggplot() + geom_sf(data = SA, size = 0.1) + 
  geom_raster(data = Priority2, aes(x = x, y = y, fill = Priority))

P <- P + scale_fill_manual(name = "Priority", values = c("#006d2c", 
                                                         "#31a354", "#d7c29e"))


P <- P + ylab("") + xlab("") + theme_bw()


P + facet_zoom(xlim = c(-87.117, -82.56), 
               ylim = c(5.51, 11.21), 
               horizontal = T, 
               zoom.size = 0.8, 
               shrink = F)

tiff("Priority.tiff", units = "in", width = 10, height = 8, res = 600, 
     compression = "lzw")
P
dev.off()
