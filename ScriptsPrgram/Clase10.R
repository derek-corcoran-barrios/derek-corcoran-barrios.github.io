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

ggplot() + geom_sf(data = Casos_Activos_Valpo, aes(fill = Activos_por_100.000), size = 0.1) +
  facet_wrap(~Fecha) +
  scale_fill_gradient2(name = "",
                       low = muted("blue"), high = muted("red"), midpoint = median(Casos_Activos_Valpo$Activos_por_100.000)) +
  theme_bw() +
  theme(legend.position = "bottom") +
  labs(title = "Prevalencia de Región de Valparaíso por Comuna", 
       subtitle = paste("Actualizado", max(Casos_Activos_Valpo$Fecha)), 
       caption = "Datos: https://github.com/MinCiencia/Datos-COVID19", 
       y = NULL, x = NULL) 

#### Agregamos puntos

# Bajamos el archivo
download.file("https://www.bcn.cl/obtienearchivo?id=repositorio/10221/10400/2/Toponimos.zip", 
              destfile = "Topo.zip")
# Lo descomprimimos
unzip("Topo.zip")
## Leemos el shapefile y nos quedamos solo con valparaíso
## continenal
Topo <- read_sf("Toponimos.shp") %>% 
  dplyr::filter(Region == "DE VALPARAISO", Clase_Topo == "Centro Poblado", Nombre %in% c("Los Andes", "Quilpué", 
                                                                                         "La Ligua", "Quillota", "San Antonio", "San Felipe", "Valparaíso")) %>% 
  st_crop(Casos_Activos_Valpo)



G <- ggplot() + geom_sf(data = Casos_Activos_Valpo, aes(fill = Activos_por_100.000), size = 0.1) +
  geom_sf(data = Topo) +
  geom_text_repel(data = Topo, aes(label = Nombre, geometry = geometry), stat = "sf_coordinates", force = 20) + 
  facet_wrap(~Fecha) +
  scale_fill_gradient2(name = "",
                       low = muted("blue"), high = muted("red"), midpoint = median(Casos_Activos_Valpo$Activos_por_100.000)) +
  theme_bw() +
  theme(legend.position = "bottom") +
  labs(title = "Prevalencia de Región de Valparaíso por Comuna", 
       subtitle = paste("Actualizado", max(Casos_Activos_Valpo$Fecha)), 
       caption = "Datos: https://github.com/MinCiencia/Datos-COVID19", 
       y = NULL, x = NULL) 


#### Exportar


tiff("Mapa1.tiff", units = "in", 
     width = 10, height = 5, 
     res = 600, compression = "lzw")

print(G)

dev.off()

#### Rasters

download.file("https://ndownloader.figshare.com/files/21843771", 
              destfile = "Priority.tiff")
Priority <- raster("Priority.tiff")
plot(Priority, colNA = "black")

data("countriesHigh")


SA <- countriesHigh %>% 
  st_as_sf() %>% 
  st_make_valid() %>% 
  st_crop(raster::extent(Priority))

ggplot() + 
  geom_sf(data = SA)


values(Priority) <- ifelse(is.na(values(Priority)), 0, values(Priority))


MASK <- rasterize(SA, Priority, field = 1)

plot(MASK, colNA = "black")

Priority  <- Priority*MASK

plot(Priority, colNA = "black")

### Vamos a tranformarlo para graficar

Priority2 <- Priority %>%
  as("SpatialPixelsDataFrame") %>% 
  as.data.frame() %>% 
  mutate(Prioridad = case_when(layer >= 0.97 ~ "Alta prioridad",
                               layer >= 0.87 & layer < 0.97 ~ "Prioridad media",
                               layer == 0 ~ "Altamente desarrollados")) %>% 
  dplyr::filter(!is.na(Prioridad)) %>% 
  mutate(Prioridad = fct_relevel(Prioridad, "Alta prioridad", "Prioridad media"))



ggplot() +
  geom_raster(data = Priority2, aes(x = x, y = y, fill = Prioridad)) +
 geom_sf(data = SA, size = 0.5, alpha = 0) +
  labs(x = NULL, y = NULL) +
  scale_fill_manual(name = "Sitios prioritarios", values = c("#006d2c", 
                                                             "#31a354", "#d7c29e")) +
  theme_bw()
  


ggplot() +
  geom_raster(data = Priority2, aes(x = x, y = y, fill = Prioridad)) +
  geom_sf(data = SA, size = 0.5, alpha = 0) +
  labs(x = NULL, y = NULL) +
  scale_fill_manual(name = "Sitios prioritarios", values = c("#006d2c", 
                                                             "#31a354", "#d7c29e")) +
  theme_bw()+ facet_zoom(xlim = c(-87.117, -82.56), ylim = c(5.51, 
                                                 11.21), horizontal = T, zoom.size = 0.8, shrink = F)
