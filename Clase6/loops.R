library(animation)
library(raster)

brks <- round(seq(floor(cellStats(bio.stack[[1]], stat = "min", na.rm = TRUE)), ceiling(cellStats(bio.stack[[8]], stat = "max", na.rm = TRUE)), length.out = 10), 0)
nb <- length(brks)-1 
colors <- rev(heat.colors(nb))
years <- as.character(seq(2000, 2070, by = 10))

bio.stack %>% walk(~plot(.x, col = colors, breaks = brks))

library(animation)
saveGIF(bio.stack %>% walk(~plot(.x, col = colors, breaks = brks)), col = colors, breaks = brks, main = paste("Mean temp", years[i]))}, movie.name = "Mean_temp.gif", img.name = "Rplot", convert = "convert", clean = TRUE)
