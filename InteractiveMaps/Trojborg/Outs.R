library(tidyverse)
library(sf)
library(raster)
library(spThin)

Trojborg_Raster <- read_rds("TrojborgRaster.rds")

Trojborg_Raster <- Trojborg_Raster[[1]] %>% projectRaster(crs ="+proj=longlat +datum=WGS84 +no_defs")

Trojborg <- read_sf("GroupsTrojborg.shp") %>% 
  st_transform(crs = "+proj=longlat +datum=WGS84 +no_defs") %>%
  fasterize::fasterize(Trojborg_Raster, field = "Group", background = 0)

Trojborg_Outline <- read_sf("GroupsTrojborg.shp") %>% 
  st_transform(crs = "+proj=longlat +datum=WGS84 +no_defs") %>% 
  st_union() %>% 
  st_as_sf()

Trojborg_Buff <- read_sf("GroupsTrojborg.shp") %>% 
  st_buffer(dist = 30) %>% 
  st_transform(crs = "+proj=longlat +datum=WGS84 +no_defs") %>% 
    fasterize::fasterize(Trojborg_Raster, field = "Group")

Trojborg_Large <- read_sf("GroupsTrojborgLarge.shp") %>% 
  st_transform(crs = "+proj=longlat +datum=WGS84 +no_defs") %>% 
  fasterize::fasterize(Trojborg_Raster, field = "Group")

Test <- (Trojborg_Large - Trojborg)

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

Centroids <- st_read("Final_Centroids_Trojborg.shp")

ggplot() + geom_sf(data = l, aes(fill = as.factor(Group))) + 
  geom_sf(data = Centroids, aes(color = as.factor(Group)))




Groups <- unique(Centroids$Group)

Final_ones <- list()

for(i in 1:length(Groups)){
  Temp_Pol <- l %>% dplyr::filter(Group == Groups[i])
  Temp_Rast <- fasterize::fasterize(Temp_Pol, Trojborg_Raster)
  Temp_Point <- Centroids %>% 
    dplyr::filter(Group == Groups[i])
  
  set.seed(i)
  Out_Random <- dismo::randomPoints(mask = Temp_Rast, 1000)  %>% 
    as.data.frame()
  
  Coords <- Out_Random
  
  Out_Random <- Out_Random %>% 
    st_as_sf(coords = c(1,2), crs ="+proj=longlat +datum=WGS84 +no_defs") 
  #  mutate(Group = Groups[i])
  Distances <- Out_Random %>% 
    st_distance(Trojborg_Outline) %>% 
    as.numeric()
  
  Coords$Distances <- Distances
  
  
  Coords <- Coords %>% dplyr::filter(Distances > 50) %>% mutate(Group = Groups[i])
  NewCoords <- spThin::thin(loc.data = Coords,
                            lat.col = "y",
                            long.col = "x",
                            spec.col = "Group",
                            verbose = F,
                            out.dir = getwd(),
                            thin.par = 0.05,
                            reps = 1,
                            locs.thinned.list.return = T, 
                            write.files = F,
                            write.log.file = F) 
  
  Out_Random <- NewCoords[[1]] %>% 
    st_as_sf(coords = c(1,2), crs ="+proj=longlat +datum=WGS84 +no_defs") %>%  
   mutate(Group = Groups[i]) %>% 
    tibble::rowid_to_column()
  
  Temp_Point$Distance <-  st_distance(Temp_Point, Temp_Pol) %>% as.numeric()
  Temp_Point <- Temp_Point %>% group_by(rowid) %>% dplyr::filter(Distance == min(Distance))
  Final_points <- list()
  for(j in 1:nrow(Temp_Point)){
    To_Match <- Temp_Point[j,]
    Dist_To_Match <- st_distance(To_Match, Out_Random) %>% as.numeric()
    Matched <- Out_Random[Dist_To_Match == min(Dist_To_Match),]
    Out_Random <- Out_Random[Dist_To_Match != min(Dist_To_Match),]
    Code <- To_Match %>% separate(col = Code, into = c("Group1", "id", "treatment")) 
    Matched <- cbind(Matched, Code) %>% mutate(Code = paste(Group, id, "D", sep = "_")) %>% 
      dplyr::select("Group", "lat", "long", "Code")
    Final_points[[j]] <- Matched %>% mutate(rowid = To_Match$rowid) %>% relocate(rowid, .before = everything())
  }
  Final_points <- Final_points %>% reduce(rbind)
  Final_ones[[i]] <- Final_points
}

Final_ones <- Final_ones %>% reduce(rbind)

ggplot() + geom_sf(data = Final_points, shape=21, aes(color = "blue", fill = as.factor(rowid))) + geom_sf(data = Temp_Point, shape=21, aes(color = "red", fill = as.factor(rowid)))


saveRDS(Final_ones, "Final_ones_out.Trojborg.rds")

ToGPX <- Centroids %>% rbind(Final_ones) %>% arrange(Code) %>% dplyr::select(Code) %>% 
  st_transform("+proj=longlat + ellps=WGS84") %>% 
  as_Spatial()

# use the ID field for the names
ToGPX@data$name <- ToGPX@data$Code  
library(rgdal)
#Now only write the "name" field to the file
writeOGR(ToGPX["name"], driver="GPX", layer="waypoints", 
         dsn="TreatmentsTrojborg.gpx")

read_sf("TreatmentsTrojborg.gpx")
