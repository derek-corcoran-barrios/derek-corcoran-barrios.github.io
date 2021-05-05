library(leaflet)

# Read in data

Bombus <- read.csv("https://raw.githubusercontent.com/derek-corcoran-barrios/derek-corcoran-barrios.github.io/master/Presentaciones_Espacial/Species.csv")

# Subset columns

Bombus <- Bombus[,c(3,5:7,9)]

# Change column name to abundance

colnames(Bombus)[5] <- "Abundance"

Species <- split(Bombus, Bombus$species)
