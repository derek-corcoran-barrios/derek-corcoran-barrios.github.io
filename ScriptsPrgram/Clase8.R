library(raster)
library(rworldxtra)
library(sf)
library(tidyverse)

data("countriesHigh")
Datos <- read_csv("https://raw.githubusercontent.com/derek-corcoran-barrios/derek-corcoran-barrios.github.io/master/Presentaciones_Espacial/Bombus.csv")
## Miremos los datos

Datos <- Datos %>% 
  st_as_sf(coords = c(5,6), crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")

## ademas de tranformar en sf, cortaremos al extent de los datos

Map <- countriesHigh %>% 
  st_as_sf() %>% 
  st_crop(Datos)

## Grafiquemos ambos datos

ggplot() + geom_sf(data = Map) + 
  geom_sf(data = Datos) +
  theme_bw()

## exportar a shapefile
write_sf(Datos, "Datos.shp")


## Haciendo mas con los mapas

ggplot() + geom_sf(data = Map) + 
  geom_sf(data = Datos, aes(color = species, size = Measurement), alpha = 0.3) +
  theme_bw()


ggplot() + geom_sf(data = Map) + 
  geom_sf(data = Datos, aes(color = species, size = Measurement), alpha = 0.3) +
  facet_wrap(~species) +
  theme_bw()

## Hacer desaparecer la leyenda

ggplot() + geom_sf(data = Map) + 
  geom_sf(data = Datos, aes(color = species, size = Measurement)) +
  facet_wrap(~species) +
  theme_bw() +
  theme(legend.position = "none")

## Leyenda abajo

ggplot() + geom_sf(data = Map) + 
  geom_sf(data = Datos, aes(color = species, size = Measurement)) +
  facet_wrap(~species) +
  theme_bw() +
  theme(legend.position = "bottom")


### Filtrar solo a B. impatiens

B_impatiens <- Datos %>% 
  dplyr::filter(species == "Bombus impatiens")


B_bifarius <- Datos %>% 
  dplyr::filter(species == "Bombus bifarius")

###

ggplot() + geom_sf(data = Map) + 
  geom_sf(data = B_impatiens, aes(size = Measurement)) +
  theme_bw()

ggplot() + geom_sf(data = Map) + 
  geom_sf(data = B_bifarius, aes(size = Measurement)) +
  theme_bw()

## Descargar datos climaticos

Bioclim <- getData(name = "worldclim", var = "bio", res = 2.5) %>% 
  crop(Datos)

## Me quedo solo con algunas variables

Bioclim <- Bioclim[[c(1,7,12,15)]]


### Extraigo los datos de las bases bioclimaticas para 
### los puntos donde esta la especie

clima <- Bioclim %>% raster::extract(B_impatiens) %>% 
  as.data.frame()

B_impatiens <- B_impatiens %>% bind_cols(clima)


clima <- Bioclim %>% raster::extract(B_bifarius) %>% 
  as.data.frame()

B_bifarius <- B_bifarius %>% bind_cols(clima)

### A modelar

FitLM_impatiens <- lm(Measurement ~ bio1 + I(bio1^2) + bio7 + I(bio7^2)+ bio12 + I(bio12^2) + bio15 +I(bio15^2), data = B_impatiens)

FitLM_bifarius <- lm(Measurement ~ bio1 + I(bio1^2) + bio7 + I(bio7^2)+ bio12 + I(bio12^2) + bio15 +I(bio15^2), data = B_bifarius)


Abund_impatiens <- predict(Bioclim, FitLM_impatiens)

Abund_bifarius <- predict(Bioclim, FitLM_bifarius)


## GLM

FitLM_impatiens <- glm(Measurement ~ bio1 + I(bio1^2) + bio7 + I(bio7^2)+ bio12 + I(bio12^2) + bio15 +I(bio15^2), data = B_impatiens, family = poisson)

FitLM_bifarius <- glm(Measurement ~ bio1 + I(bio1^2) + bio7 + I(bio7^2)+ bio12 + I(bio12^2) + bio15 +I(bio15^2), data = B_bifarius, family = poisson)

Abund_impatiens <- predict(Bioclim, FitLM_impatiens, type = "response")

Abund_bifarius <- predict(Bioclim, FitLM_bifarius, type = "response")


Abund_impatiens_DF <- Abund_impatiens %>% 
  as("SpatialPixelsDataFrame") %>% 
  as.data.frame() %>% 
  rename(Abundancia = layer)


ggplot() + 
  geom_raster(data = Abund_impatiens_DF, aes(x = x, y = y,fill = Abundancia)) +
  geom_sf(data = Map, alpha = 0) +
  geom_sf(data = B_impatiens, aes(size = Measurement)) +
  theme_bw() +
  scale_fill_viridis_c(option = "plasma") +
  labs(x= NULL, y = NULL)


## Para la otra especie

Abund_bifarius_DF <- Abund_bifarius %>% 
  as("SpatialPixelsDataFrame") %>% 
  as.data.frame() %>% 
  rename(Abundancia = layer)

ggplot() + 
  geom_raster(data = Abund_bifarius_DF, aes(x = x, y = y,fill = Abundancia)) +
  geom_sf(data = Map, alpha = 0) +
  geom_sf(data = B_bifarius, aes(size = Measurement)) +
  theme_bw() +
  scale_fill_viridis_c(option = "plasma")


### Seleccion de modelos

FitLM_impatiens1 <- glm(Measurement ~ bio1 + I(bio1^2) + bio7 + I(bio7^2)+ bio12 + I(bio12^2) + bio15 +I(bio15^2), data = B_impatiens, family = poisson)

FitLM_impatiens2 <- glm(Measurement ~ bio1 + I(bio1^2) + bio7 + I(bio7^2)+ bio12 + I(bio12^2) + bio15, data = B_impatiens, family = poisson)

library(broom)

glance(FitLM_impatiens1) %>% pull(AIC)

glance(FitLM_impatiens2) %>% pull(AIC)

# Si hay una diferencia de al menos 2 hay diferencias importantes


FitLM_bifarius1 <- glm(Measurement ~ bio1 + I(bio1^2) + bio7 + I(bio7^2)+ bio12 + I(bio12^2) + bio15 +I(bio15^2), data = B_bifarius, family = poisson)

FitLM_bifarius2 <- glm(Measurement ~ bio1 + I(bio1^2) + bio7 + I(bio7^2)+ bio12 + bio15 +I(bio15^2), data = B_bifarius, family = poisson)

FitLM_bifarius3 <- glm(Measurement ~ I(bio1^2) + I(bio7^2) +  I(bio15^2), data = B_bifarius, family = poisson)

glance(FitLM_bifarius1) %>% pull(AIC)

glance(FitLM_bifarius2) %>% pull(AIC)

glance(FitLM_bifarius3) %>% pull(AIC)
