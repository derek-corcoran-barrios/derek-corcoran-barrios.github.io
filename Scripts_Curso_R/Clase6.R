library(tidyverse)

download.file("https://github.com/derek-corcoran-barrios/TH_Data/blob/master/T&H.zip?raw=true", "Botones.zip")
unzip("Botones.zip")

### leer el un sitio

library(tidyverse)
library(lubridate)

# loop manual

H1F102Tem <- read_csv("T&H/H1F102Tem.csv") %>% 
  mutate(DateH = dmy_hm(`Date/Time`), Date = date(DateH), Month = month(DateH), Year = year(DateH), Name = "H1F102")  %>% 
  dplyr::select(-`Date/Time`, -Unit, -a) %>% group_by(Date, Month, Year, Name) %>% 
  summarise_at(.vars = "Value",list(Mean = mean, Min = min, Max = max)) %>% 
  ungroup()

H1F105Tem <- read_csv("T&H/H1F105Tem.csv") %>% 
  mutate(DateH = dmy_hm(`Date/Time`), Date = date(DateH), Month = month(DateH), Year = year(DateH), Name = "H1F105")  %>% 
  dplyr::select(-`Date/Time`, -Unit, -a) %>% group_by(Date, Month, Year, Name) %>% 
  summarise_at(.vars = "Value",list(Mean = mean, Min = min, Max = max)) %>% 
  ungroup()


ggplot(H1F102Tem, aes(x = DateH, y = Value)) + geom_path()



### Lista de archivos

Archivos <- list.files(path = "T&H", pattern = ".csv", full.names = T)

Archivos <- Archivos[str_detect(Archivos, "Tem")]

Nombres <- Archivos %>% str_remove_all("T&H/") %>% str_remove_all("Tem.csv")

Temp <- map(.x = Archivos, .f = read_csv)

Temp <- Archivos %>% map(read_csv) %>% 
  map(~mutate(.x, DateH = dmy_hms(`Date/Time`, truncated = 1), Date = date(DateH), Month = month(DateH), Year = year(DateH))) %>% 
  map(~dplyr::select(.x,-`Date/Time`, -Unit, -a)) %>% 
  map2(.y = Nombres,~mutate(.x, Name = .y)) %>% 
  map(~group_by(.x,Date, Month, Year, Name)) %>% 
  map(~summarise_at(.x,.vars = "Value",list(Mean = mean, Min = min, Max = max))) %>% 
  map(ungroup) %>% 
  reduce(bind_rows)

### For loops

library(raster)
library(animation)

githubURL <- ("https://raw.githubusercontent.com/derek-corcoran-barrios/derek-corcoran-barrios.github.io/master/Clase6/bio.stack.rds")
download.file(githubURL, "bio.stack.rds", method = "curl")

bio.stack <- readRDS("bio.stack.rds")
plot(bio.stack)

Years <- paste("Año", seq(2000, 2070, by = 10))

brks <- seq(from = floor(min(cellStats(bio.stack, min))), to = ceiling(max(cellStats(bio.stack, max))), length.out = 10)
brks <- round(brks)
nb <- length(brks) - 1
colors <- rev(heat.colors(nb))

for(i in 1:8){
  plot(bio.stack[[i]], main = Years[i], breaks = brks, col = colors)
}


saveGIF(for(i in 1:8){
  plot(bio.stack[[i]], main = Years[i], breaks = brks, col = colors)
}, "Temp.gif")



data("iris")

#####

iris %>% 
  summarise_at(.vars = c("Petal.Length", "Sepal.Length"), .funs = list(Media= mean, Dispersion = sd))

iris %>% 
  summarise(Var = mean(Petal.Length)/sd(Sepal.Length + Sepal.Width))

iris %>% 
  dplyr::select(ends_with("Length")) %>% summarise_all(.funs = list(Media= mean, Dispersion = sd))



irissp <- iris %>% group_split(Species)


PetalR <- function(x){
  Result <- x %>% dplyr::select(starts_with("Petal")) %>% mutate(Ratio = Petal.Length/Petal.Width) %>% summarise(Ratio = mean(Ratio)) %>% pull(Ratio)
  return(Result)
}


irissp[[3]]$Sepal.Length


names(irissp) <- c("setosa","versicolor", "virginica")


length(irissp)
