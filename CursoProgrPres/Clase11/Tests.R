library(rgee)

# ee_reattach() # reattach ee as a reserved word

ee_Initialize()



col<-ee$ImageCollection('COPERNICUS/S2_SR')
point <- ee$Geometry$Point(-71.6002957, -33.0055093)
start <- ee$Date("2020-02-11")
end <- ee$Date("2020-02-20")
filter<-col$filterBounds(point)$filterDate(start,end)
img <- filter$first()


## Ver varias bandas
vPar <- list(bands = c("B4", "B3", "B2"),
             min = 100,max = 8000,             
             gamma = c(1.9,1.7,1.7))

##
Map$setCenter(-71.6002957, -33.0055093, zoom = 10)
Map$addLayer(img, vPar, "True Color Image")


getNDVI <- function(image) {  
  return(image$normalizedDifference(c("B8", "B4")))
  }
ndvi1 <- getNDVI(img)

start2 <- ee$Date("2020-07-11")
end2 <- ee$Date("2020-07-20")
filter2<-col$filterBounds(point)$filterDate(start2,end2)
img2 <- filter2$first()
ndvi2 <- getNDVI(img2)

ndviPar <- list(palette = c(  
  "#cccccc", "#f46d43", "#fdae61", "#fee08b",  "#d9ef8b", "#a6d96a", "#66bd63", "#1a9850"),
  min=0,max=1)


Map$setCenter(-71.6002957, -33.0055093, zoom = 10)
Map$addLayer(ndvi1, ndviPar, "NDVI verano") + Map$addLayer(ndvi2, ndviPar, "NDVI invierno")

library(raster)
library(sf)
library(tidyverse)

ee_x <- st_read(system.file("shape/nc.shp", package = "sf")) 

ValpoVina <- getData("GADM", country = "CHL", level = 2) %>% 
  st_as_sf() %>% 
  dplyr::filter(NAME_1 == "Valparaíso", NAME_2 %in% c("Valparaíso")) %>%
  st_transform(st_crs(ee_x)) %>% 
  sf_as_ee()
#  st_set_crs("+proj=utm +zone=19 +south +datum=WGS84 +units=m +no_defs")

start <- ee$Date("2020-01-01")
end <- ee$Date("2020-12-31")


col<-ee$ImageCollection("LANDSAT/LE07/C01/T1_8DAY_NDVI")
filter<-col$filterBounds(point)$filterDate(start,end)$select("NDVI")

ee_ndvi_valpo <- ee_extract(x = filter, y = ValpoVina, sf = FALSE)

ee_ndvi_valpo2 <- ee_ndvi_valpo %>% pivot_longer(everything(), values_to = "NDVI") %>% mutate(Fecha = lubridate::ymd(str_remove_all(name, "X")))




start <- ee$Date("2014-01-01")
end <- ee$Date("2020-12-31")


col<-ee$ImageCollection("LANDSAT/LE07/C01/T1_8DAY_NDVI")
filter<-col$filterBounds(point)$filterDate(start,end)$select("NDVI")

ee_ndvi_valpo <- ee_extract(x = filter, y = ValpoVina, sf = FALSE)

ee_ndvi_valpo2 <- ee_ndvi_valpo %>% pivot_longer(everything(), values_to = "NDVI") %>% mutate(Fecha = lubridate::ymd(str_remove_all(name, "X")))
ggplot(ee_ndvi_valpo2, aes(x = Fecha, y = NDVI)) + geom_path() + geom_point()


ee_ndvi_valpo2 <- ee_ndvi_valpo2 %>% mutate(Dia = lubridate::yday(Fecha), Mes =  lubridate::month(Fecha))

ggplot(ee_ndvi_valpo2, aes(x = Dia, y = NDVI)) + geom_point()

ee_ndvi_valpo_summary <- ee_ndvi_valpo2 %>% group_by(Mes) %>% summarise(sd = sd(NDVI), NDVI = mean(NDVI))

ggplot(ee_ndvi_valpo_summary, aes(x = Mes, y = NDVI)) + geom_ribbon(aes(ymax = NDVI + sd, ymin = NDVI -sd), alpha = 0.3, fill = "red") + geom_point() + geom_path()
