library(leaflet)

# Read in data

Bombus <- read.csv("https://raw.githubusercontent.com/derek-corcoran-barrios/derek-corcoran-barrios.github.io/master/Presentaciones_Espacial/Species.csv")

# Subset columns

Bombus <- Bombus[,c(3,5:7,9)]

# Change column name to abundance

colnames(Bombus)[5] <- "Abundance"



# First quick map

M <- leaflet() %>% 
  addTiles() %>% 
  addCircles(data = Bombus, lng = ~Longitude, ~Latitude) 

M

## Some control

M %>%  addMeasure(primaryLengthUnit = "meters", primaryAreaUnit = "hectare")

# color by species

pal <- colorFactor(c("red", "blue"), domain = unique(Bombus$species))

  
  M <- leaflet() %>% 
    addTiles() %>% 
    addCircles(data = Bombus, lng = ~Longitude, ~Latitude, color = ~pal(species), fillColor = ~pal(species))  
  
  M %>% addLegend(pal = pal, values = unique(Bombus$species))

  ## Add popup or abundace
  
  M <- leaflet() %>% 
    addTiles() %>% 
    addCircles(data = Bombus, lng = ~Longitude, ~Latitude, 
               color = ~pal(species), fillColor = ~pal(species),
               popup = ~Site_name, label = ~Abundance)
  
  M %>% addLegend(pal = pal, values = unique(Bombus$species))
  
  ## Or size of circles
    
  M <- leaflet() %>% 
    addTiles() %>% 
    addCircleMarkers(data = Bombus, lng = ~Longitude, ~Latitude, 
                     color = ~pal(species), fillColor = ~pal(species),
                     popup = ~Site_name, label = ~Abundance,
                     radius = 10*(Bombus$Abundance/max(Bombus$Abundance)))
  
  M %>% addLegend(pal = pal, values = unique(Bombus$species))

## To hide/ control things you need a group
  
  Species <- split(Bombus, Bombus$species)
  
  M <- leaflet() %>% 
    addTiles() %>% 
    addCircles(data = Species[[1]], lng = ~Longitude, ~Latitude, color = ~pal(species), fillColor = ~pal(species), group = names(Species)[1],
               popup = ~Site_name, label = ~Abundance)  %>% 
    addCircles(data = Species[[2]], lng = ~Longitude, ~Latitude, color = ~pal(species), fillColor = ~pal(species), group = names(Species)[2],
               popup = ~Site_name, label = ~Abundance) %>% 
    addLegend(pal = pal, values = unique(Bombus$species))
  
  
M %>% addLayersControl(overlayGroups = names(Species))


## Try to use one species and use the colorNumeric function to get an abundance color legend