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

ValpoVina <- getData("GADM", country = "CHL", level = 2) %>% 
  st_as_sf() %>% 
  dplyr::filter(NAME_1 == "Valparaíso", NAME_2 %in% c("Valparaíso"))

start <- ee$Date("2020-01-01")
end <- ee$Date("2020-12-31")

filter<-col$filterBounds(point)$filterDate(start,end)
img <- filter$first()
ndvi <- getNDVI(img)

ee_ndvi_valpo <- ee_extract(x = ndvi, y = ValpoVina, sf = FALSE)
