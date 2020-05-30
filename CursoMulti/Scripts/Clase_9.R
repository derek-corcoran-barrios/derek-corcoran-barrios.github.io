library(tidyverse)
library(caret)

Train <- read_csv("Train.csv")


ggplot(Train, aes(x = Fecha, y = Activos_5_por_100.000)) + geom_path(aes(color = Comuna)) + theme_bw() + theme(legend.position = "none")



Graph_Slice <- function(Slices = Slices) {
  Slice <- list()
  for (i in 1:length(Slices$test)) {
    Window <- Train[Slices$train[[i]], ] %>% mutate(rep = as.character(i), 
                                                    class = "Window (Train)")
    Horizon <- Train[Slices$test[[i]], ] %>% mutate(rep = as.character(i), 
                                                    class = "Horizon (Test)")
    Slice[[i]] <- bind_rows(Window, Horizon)
  }
  Slices <- Slice %>% purrr::reduce(bind_rows)
  ggplot(Slices, aes(x = Fecha, y = Activos_5_por_100.000, group = Comuna)) + geom_path(aes(color = class)) + 
    facet_wrap(~rep) + theme_bw()
}


Slices <- createTimeSlices(Train$Activos_5_por_100.000, horizon = 365, initialWindow = 365 * 3, fixedWindow = T, skip = 365)

Graph_Slice(Slices)

#####

Train <-  Train %>% arrange(Fecha)

Slices <- createTimeSlices(Train$Activos_5_por_100.000, horizon = 365, initialWindow = 365 * 3, fixedWindow = T, skip = 365)

Graph_Slice(Slices)


####



Slices <- createTimeSlices(Train$Activos_5_por_100.000, horizon = 346*2, initialWindow = 346 * 1, fixedWindow = T, skip = 346)

Graph_Slice(Slices)


#####

Slices <- createTimeSlices(Train$Activos_5_por_100.000, horizon = 346*5, initialWindow = 346 * 5, fixedWindow = F, skip = 346)

Graph_Slice(Slices)
caret::postResample()

