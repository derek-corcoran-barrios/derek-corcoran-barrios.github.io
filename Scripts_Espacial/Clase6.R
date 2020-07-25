setwd("~/derek-corcoran-barrios.github.io/Scripts_Espacial")

library(BIEN)
library(dismo)
library(ENMeval)
library(maxnet)
library(raster)
library(rworldxtra)
library(sf)
library(tidyverse)

## Descargar presencias

N_pumilio <- BIEN_occurrence_species(species = "Nothofagus pumilio")

## Tranformamos en SF

N_pumilio_SF <- N_pumilio %>% st_as_sf(coords = c(3, 2), 
                                       crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")

## Generar un buffer

Hull <- N_pumilio_SF %>% st_union() %>% st_convex_hull()

Buffer <- Hull %>% st_buffer(dist = 1) %>% st_as_sf()

## Poligono map

data("countriesHigh")
SA <- countriesHigh %>% st_as_sf() %>% st_make_valid() %>% st_crop(Buffer)

ggplot() + 
  geom_sf(data = SA) +
  geom_sf(data = N_pumilio_SF) + 
  theme_bw()

## Bajamos capas climaticas

Bioclimatic <- getData(name = "worldclim", var = "bio", res = 0.5, 
                       lon = -70, lat = -50)

## capas climaticas
Bioclimatic <- Bioclimatic %>% crop(Buffer) %>% trim()
  
## Cortamos el Tile
names(Bioclimatic) <- str_remove_all(names(Bioclimatic), "_43")
  
#### Generar un background


set.seed(2020)

Pres <- N_pumilio %>% dplyr::select(longitude, latitude) %>% 
  mutate(Pres = 1)

Aus <- dismo::randomPoints(mask = Bioclimatic[[1]], n = 5000) %>% 
  as.data.frame() %>% rename(longitude = x, latitude = y) %>% 
  mutate(Pres = 0)  
  
  
  
  
Pres_Aus <- bind_rows(Pres, Aus)
Pres_Aus_Sf <- Pres_Aus %>% st_as_sf(coords = c(1, 2), 
                                     crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")

Condiciones <- raster::extract(Bioclimatic, Pres_Aus_Sf) %>% 
  as.data.frame() %>% bind_cols(Pres_Aus)

ggplot(Condiciones, aes(x = bio1, y = bio12)) +
  geom_point(aes(color = factor(Pres)), alpha = 0.05) +
  geom_density2d(aes(color = factor(Pres)))

## Primer modelo 

Mod1 <- maxnet(p = Condiciones$Pres, data = Condiciones[,1:19], 
               regmult = 1, maxnet.formula(p = Condiciones$Pres, data = Condiciones[,1:19], classes = "lq"), clamp = F)


### Veamos respuestas de variables

plot(Mod1, c("bio2"), type = "cloglog")


Mod2 <- maxnet(p = Condiciones$Pres, data = Condiciones[, 1:19], 
               regmult = 1, maxnet.formula(p = Condiciones$Pres, data = Condiciones[, 
                                                                                    1:19], classes = "l"))
Mod3 <- maxnet(p = Condiciones$Pres, data = Condiciones[, 1:19], 
               regmult = 1, maxnet.formula(p = Condiciones$Pres, data = Condiciones[, 
                                                                                    1:19], classes = "lh"))

plot(Mod3, c("bio2"))

Mod4 <- maxnet(p = Condiciones$Pres, data = Condiciones[, 1:19], 
               regmult = 1)

Prediction <- predict(Bioclimatic, Mod4, type = "cloglog")

### Transformar en Presencia Ausencia

Eval <- dismo::evaluate(p = Pres[, 1:2], a = Aus[, 1:2], model = Mod4, 
                        x = Bioclimatic, type = "cloglog")




EvalDF <- Eval@confusion %>% as.data.frame %>% mutate(Threshold = Eval@t) %>% 
  mutate(TP_TN = (tp/nrow(N_pumilio)) + (tn/5000))


EvalThres <- EvalDF %>% dplyr::filter(TP_TN == max(TP_TN))


Prediction <- Prediction %>% as("SpatialPixelsDataFrame") %>% as.data.frame() %>% mutate(Binary = ifelse(layer >= 
                                                      EvalThres$Threshold, "Presencia", "Ausencia"))


### USando ENMeval

Results <- ENMevaluate(occ = N_pumilio[, c(3, 2)], env = Bioclimatic, 
                       RMvalues = c(0.75, 1, 1.25), n.bg = 5000, method = "randomkfold", 
                       overlap = F, kfolds = 5, bin.output = T, fc = c("L", "LQ", 
                                                                       "LQP"), rasterPreds = T)


View(Results@results)

Models <- Results@results
Models$ID <- 1:nrow(Models)
Models <- Models %>% arrange(AICc)


BestModels <- Results@models[[Models$ID[1]]]
## Prediccion del mejor modelo
Prediction <- predict(Bioclimatic, BestModels, type = "cloglog") 


plot(Prediction, colNA = "black")


