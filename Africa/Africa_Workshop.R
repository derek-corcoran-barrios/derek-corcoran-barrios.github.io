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

## Subsetting using numeric variables

MedianGDP <- median(Africa$GDP_MD_)

Richest <- Africa %>% dplyr::filter(GDP_MD_ > MedianGDP)

## Lets say we just want to see climate from Nambibia

# First we create a polygon of Nambibia

Namibia <- Africa %>% dplyr::filter(SOVEREI == "Namibia")

# Then crop climate to that

Clim_Namibia <- Clim %>% crop(Namibia)

#If we plot it we can see that it takes all the *Bounding box*

Clim_Namibia_DF <- Clim_Namibia %>% 
  as("SpatialPixelsDataFrame") %>% 
  as.data.frame()

ggplot() + 
  geom_raster(data = Clim_Namibia_DF, aes(x = x, y = y, fill = Temp)) +
  geom_sf(data = Namibia, alpha = 0) +
  labs(x = NULL, y = NULL) +
  theme_bw() +
  scale_fill_viridis_c()
## Create vectorial variables with mutate

# Lets generate GDP_Per_Capita
# We will divide `GDP_MD_` by `POP_EST` with mutate# 

Africa <- Africa %>% mutate(GDP_Per_Capita = GDP_MD_/POP_EST)

ggplot() +
  geom_sf(data = Africa, aes(fill = GDP_Per_Capita)) +
  scale_fill_viridis_c() +
  theme_bw()

## Create Grid variables

# Temperature in Fahrenheit

Fahrenheit <- (Clim[[1]]*(9/5)) + 32

plot(Fahrenheit)

## Generate a model


ForModel <- Abundance_sf %>% 
  dplyr::filter(Best_guess_binomial == "Zosterops poliogaster") %>% 
  dplyr::select(Effort_corrected_measurement)

Area <- Clim %>% crop(ForModel)

Data <- raster::extract(Area, ForModel) %>% as.data.frame()

ForModel <- bind_cols(ForModel, Data)

Model <- glm(Effort_corrected_measurement ~ Temp + Prec, family = poisson, data = ForModel)

Prediction <- predict(Area, Model, type = "response")

plot(log(Prediction))
