library(rgee)
ee_Initialize()

col <- ee$ImageCollection("COPERNICUS/S2_SR")

point <- ee$Geometry$Point(-71.6002957, -33.0055093)

start <- ee$Date("2020-09-10")
end <- ee$Date("2020-09-30")

filter <- col$filterBounds(point)$filterDate(start, end)

img <- filter$first()

vPar <- list(bands = c("B4", "B3", "B2"), min = 100, max = 8000, 
             gamma = c(1.9, 1.7, 1.7))


Map$setCenter(-71.6002957, -33.0055093, zoom = 10)
Map$addLayer(img, vPar, "Color real")

### Función NDVI

getNDVI <- function(image) {
  return(image$normalizedDifference(c("B8", "B4")))
}

ndvi1 <- getNDVI(img)

ndviPar <- list(palette = c("#cccccc", "#f46d43", "#fdae61", 
                            "#fee08b", "#d9ef8b", "#a6d96a", "#66bd63", "#1a9850"), min = 0, 
                max = 1)


Map$setCenter(-71.6002957, -33.0055093, zoom = 10)
Map$addLayer(ndvi1, ndviPar, "NDVI verano")


###

library(raster)
library(sf)
library(tidyverse)
ee_x <- st_read(system.file("shape/nc.shp", package = "sf"))
ValpoVina <- getData("GADM", country = "CHL", level = 3) %>% 
  st_as_sf() %>% dplyr::filter(NAME_1 == "Valparaíso", NAME_2 %in% c("Los Andes", "Petorca", "Quillota", "San Antonio", 
                                                                     "San Felipe de Aconcagua", "Valparaíso")) %>% st_transform(st_crs(ee_x)) %>% sf_as_ee()

## Tomemos NDVI desde landsat 7

      start <- ee$Date("2000-01-01")
      end <- ee$Date("2020-12-31")
      col <- ee$ImageCollection("LANDSAT/LE07/C01/T1_8DAY_NDVI")
      
      filter <- col$filterBounds(point)$filterDate(start, end)$select("NDVI")
      
      
      ee_ndvi_valpo <- ee_extract(x = filter, y = ValpoVina, sf = TRUE)
      
      
      ee_ndvi_valpo2 <- ee_ndvi_valpo %>%  
        gather(key = "Fecha", value = "NDVI", starts_with("X20")) %>% mutate(Fecha = lubridate::ymd(str_remove_all(Fecha, "X")), Mes = lubridate::month(Fecha)) %>% group_by(Mes,NAME_3) %>% 
        summarise(NDVI = mean(NDVI, na.rm = T))
      
      ggplot() + geom_sf(data = ee_ndvi_valpo2, aes(fill = NDVI))  + facet_wrap(~Mes) + scale_fill_viridis_c()

      
      "Magallanes y Antártica Chilena"      

ggplot(ee_ndvi_valpo2, aes(x = Fecha, y = NDVI)) + 
  geom_point() +
  geom_path()


### 6 años

start <- ee$Date("2005-01-01")
end <- ee$Date("2020-12-31")
col <- ee$ImageCollection("LANDSAT/LE07/C01/T1_8DAY_NDVI")
filter <- col$filterBounds(point)$filterDate(start, end)$select("NDVI")
ee_ndvi_valpo <- ee_extract(x = filter, y = ValpoVina, sf = FALSE)
ee_ndvi_valpo2 <- ee_ndvi_valpo %>% pivot_longer(everything(), 
                                                 values_to = "NDVI") %>% mutate(Fecha = lubridate::ymd(str_remove_all(name,"X")), Dia = lubridate::yday(Fecha), Mes = lubridate::month(Fecha))


ggplot(ee_ndvi_valpo2, aes(x = Fecha, y = NDVI)) + 
  geom_point() +
  geom_path()

ggplot(ee_ndvi_valpo2, aes(x = Dia, y = NDVI)) + 
  geom_point() 

ee_summarise_valp0 <- ee_ndvi_valpo2 %>% 
  group_by(Mes) %>% 
  summarise(sd = sd(NDVI), NDVI = mean(NDVI))

ggplot(ee_summarise_valp0, aes(x = Mes, y = NDVI)) + 
  geom_ribbon(aes(ymax = NDVI + sd, ymin = NDVI - sd), fill = "red", alpha = 0.5) + geom_path()
