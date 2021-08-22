library(tidyverse)
library(sf)
library(raster)

Husby_Raster <- read_rds("HusbyRaster.rds")

Husby_Raster <- Husby_Raster[[1]] %>% projectRaster(crs ="+proj=longlat +datum=WGS84 +no_defs")

Husby <- read_sf("GroupsHusby.shp") %>% 
  st_transform(crs = "+proj=longlat +datum=WGS84 +no_defs") %>%
  fasterize::fasterize(Husby_Raster, field = "Group", background = 0)

Husby_Buff <- read_sf("GroupsHusby.shp") %>% 
  st_buffer(dist = 30) %>% 
  st_transform(crs = "+proj=longlat +datum=WGS84 +no_defs") %>% 
    fasterize::fasterize(Husby_Raster, field = "Group")

Husby_Large <- read_sf("GroupsHusbyLarge.shp") %>% 
  st_transform(crs = "+proj=longlat +datum=WGS84 +no_defs") %>% 
  fasterize::fasterize(Husby_Raster, field = "Group")

Test <- (Husby_Large - Husby)

values(Test) <- ifelse(values(Test) < 1, NA, values(Test))

library(stars)

Test <- stars::st_as_stars(Test)

l =  st_contour(Test, contour_lines = FALSE, breaks = 0:7) %>%
mutate(Group = case_when(layer == "[1,2)" ~ 1,
                         layer == "[2,3)" ~ 2,
                         layer == "[3,4)" ~ 3,
                         layer == "[4,5)" ~ 4,
                         layer == "[5,6)" ~ 5,
                         layer == "[6,7)" ~ 6)) %>%
dplyr::select(Group) %>% 
  mutate(Group = case_when(Group == 1 ~ "A1",
                           Group == 2 ~ "A2",
                           Group == 3 ~ "B1",
                           Group == 4 ~ "B2",
                           Group == 5 ~ "C1",
                           Group == 6 ~ "C2"))

Centroids <- st_read("Final_Centroids_Husby.shp")

ggplot() + geom_sf(data = l, aes(fill = as.factor(Group))) + geom_sf(data = Centroids, aes(color = as.factor(Group)))




Groups <- unique(l$Group)

for(i in 1:length(Groups)){
  Temp_Pol <- l %>% dplyr::filter(Group == Groups[i])
  Temp_Rast <- fasterize::fasterize(Temp_Pol, Husby_Raster)
  Temp_Point <- Centroids %>% 
    dplyr::filter(Group == Groups[i]) %>% 
    group_split()
}
