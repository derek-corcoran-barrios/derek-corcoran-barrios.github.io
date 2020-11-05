## Load the packages needed for this workshop

library(raster)
library(sf)
library(tidyverse)
  

## Read in Polygon dataset of Africa

Africa <- read_sf("Africa.shp")



## See what variables it has

# Names of datasets

colnames(Africa)

# See first few polygons 

head(Africa)

## Plot polygon

# Change POP_EST for another variable of your Choosing

ggplot() + geom_sf(data = Africa, aes(fill = POP_EST))


## Read from csv 

Abundance <- read_csv("Abundance.csv")

## Check columns for lat, long in that order
Abundance_sf <- Abundance %>% 
  st_as_sf(coords = c(9,10),crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")

##  Plot it with polygons as well

ggplot() + geom_sf(data = Africa, aes(fill = POP_EST)) + 
  geom_sf(data = Abundance_sf, aes(size = Measurement))


## Read rasters

Clim <- stack("Clim.tif")
plot(Clim, colNA = "black")

## Transform raster to DF

Clim_DF <- Clim %>% 
  as("SpatialPixelsDataFrame") %>% 
  as.data.frame()

head(Clim_DF)

# Plot 

ggplot() + geom_raster(data = Clim_DF, aes(x = x, y = y, fill = Temp)) + geom_sf(data = Africa, alpha = 0) + geom_sf(data = Abundance_sf, aes(size = Measurement))

# Subsetting and cropping 

## Subsetting Vectorial data

Southern <- Africa %>% dplyr::filter(GEO3 == "Southern Africa")

