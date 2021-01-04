library(ggforce)
library(ggrepel)
library(scales)
library(raster)
library(rworldxtra)
library(sf)
library(tidyverse)

### 
# Base de datos
githubURL <- ("https://raw.githubusercontent.com/derek-corcoran-barrios/derek-corcoran-barrios.github.io/master/Presentaciones_Espacial/Casos_Activos_Valpo.rds")
# La descargamos
download.file(githubURL, "Casos_Activos_Valpo.rds")
# La leemos
Casos_Activos_Valpo <- readRDS("Casos_Activos_Valpo.rds")
# Gráfico simple

## Agregamos una paleta
ggplot() + 
  geom_sf(data = Casos_Activos_Valpo, aes(fill = Activos_por_100.000)) +
  facet_wrap(~Fecha) +
  scale_fill_gradientn(name = "Casos activos cada\n 100.000 habitantes",
                       colors = heat.colors(10))

## Scale viridis
ggplot() + 
  geom_sf(data = Casos_Activos_Valpo, aes(fill = Activos_por_100.000)) +
  facet_wrap(~Fecha) +
  scale_fill_viridis_c(name = "Casos activos cada\n 100.000 habitantes")


## Opciones del scale viridis

ggplot() + 
  geom_sf(data = Casos_Activos_Valpo, aes(fill = Activos_por_100.000)) +
  facet_wrap(~Fecha) +
  scale_fill_viridis_c(name = "Casos activos cada\n 100.000 habitantes",
                       option = "magma", direction = -1)

ggplot() + 
  geom_sf(data = Casos_Activos_Valpo, aes(fill = Activos_por_100.000)) +
  facet_wrap(~Fecha) +
  scale_fill_viridis_c(name = "Casos activos cada\n 100.000 habitantes",
                       option = "plasma")


### Escala por bins

ggplot() + 
  geom_sf(data = Casos_Activos_Valpo, aes(fill = Activos_por_100.000)) +
  facet_wrap(~Fecha) +
  scale_fill_binned(name = "Casos activos cada\n 100.000 habitantes")


ggplot() + 
  geom_sf(data = Casos_Activos_Valpo, aes(fill = Activos_por_100.000)) +
  facet_wrap(~Fecha) +
  scale_fill_viridis_b(name = "Casos activos cada\n 100.000 habitantes",
                       breaks = seq(from = 0, to = 200, by =25)) 


## Scalefill gradient2


ggplot() + 
  geom_sf(data = Casos_Activos_Valpo, aes(fill = Activos_por_100.000)) +
  facet_wrap(~Fecha) +
  scale_fill_gradient2(name = "Casos activos cada\n 100.000 habitantes",
                       low = muted("blue"), high = muted("red"), midpoint = mean(Casos_Activos_Valpo$Activos_por_100.000),
                       )

## Efecto muted

ggplot() + 
  geom_sf(data = Casos_Activos_Valpo, aes(fill = Activos_por_100.000)) +
  facet_wrap(~Fecha) +
  scale_fill_gradient2(name = "Casos activos cada\n 100.000 habitantes",
                       low = "blue", high = "red", midpoint = mean(Casos_Activos_Valpo$Activos_por_100.000),
  )



### MAs detalles

ggplot() + geom_sf(data = Casos_Activos_Valpo, aes(fill = Activos_por_100.000)) +
  facet_wrap(~Fecha) +
  scale_fill_gradient2(name = "",
                       low = muted("blue"), high = muted("red"), midpoint = median(Casos_Activos_Valpo$Activos_por_100.000)) +
  theme(legend.position = "bottom") +
  labs(title = "Prevalencia de Región de Valparaíso por Comuna", 
       subtitle = paste("Actualizado", max(Casos_Activos_Valpo$Fecha)), 
       caption = "Datos: https://github.com/MinCiencia/Datos-COVID19", 
       y = NULL, x = NULL)

