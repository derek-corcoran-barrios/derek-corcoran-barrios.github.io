#Cargar paquetes
library(caret)
library(tidyverse)
library(mlbench)

#
data("BreastCancer")

## Exploracion de datos

transparentTheme(trans = 0.4)
featurePlot(x = BreastCancer[,2:5], y = BreastCancer$Class, plot = "pairs", auto.key = list(columns = 2))

### División en Entrenamiento y prueba

set.seed(707)
Index <- createDataPartition(BreastCancer$Class, list = FALSE, p = 0.8)
Train <- BreastCancer[Index, -1]
Test <- BreastCancer[-Index, -1]

fitControl <- trainControl(method = "repeatedcv", number = 10, repeats = 10)

gbmFit1 <- train(Class ~ ., data = Train, method = "gbm", trControl = fitControl, 
                 verbose = TRUE)

### Quito los NA

BC2 <- BreastCancer[complete.cases(BreastCancer),]

set.seed(707)
Index <- createDataPartition(BC2$Class, list = FALSE, p = 0.8)
Train <- BC2[Index, -1]
Test <- BC2[-Index, -1]

gbmFit1 <- train(Class ~ ., data = Train, method = "gbm", trControl = fitControl, 
                 verbose = TRUE)

confusionMatrix(data = predict(gbmFit1, Test), reference = Test$Class)

### Series de tiempo

Contaminacion <- read_csv("https://raw.githubusercontent.com/derek-corcoran-barrios/derek-corcoran-barrios.github.io/master/CursoMultiPres/Capitulo_7/Contaminacion.csv")

Contaminacion <- Contaminacion %>% mutate(Dias = julian(Fecha), Mes = lubridate::month(Fecha))


ggplot(Contaminacion, aes(x = Mes, y = MP25)) + geom_point() + theme_classic()

Train <- Contaminacion %>% dplyr::filter(!(lubridate::year(Fecha) %in% c(2016, 2017)))
Test <- Contaminacion %>% dplyr::filter(lubridate::year(Fecha) %in% c(2016, 2017))


### Funcion para probar crossvalidation

Graph_Slice <- function(Slices = Slices) {
  Slice <- list()
  for (i in 1:length(Slices$test)) {
    Window <- Train[Slices$train[[i]], ] %>% mutate(rep = as.character(i), class = "Window (Train)")
    Horizon <- Train[Slices$test[[i]], ] %>% mutate(rep = as.character(i), class = "Horizon (Test)")
    Slice[[i]] <- bind_rows(Window, Horizon)
  }
  Slices <- Slice %>% purrr::reduce(bind_rows)
  ggplot(Slices, aes(x = Fecha, y = MP25)) + geom_path(aes(color = class)) + facet_wrap(~rep) + 
    theme_bw()
}


Slices <- createTimeSlices(Train$MP25, horizon = 365, 
                           initialWindow = 365 * 3, 
                           fixedWindow = T, 
                           skip = 60)
Graph_Slice(Slices)


### Como usamos las ventanas y horizontes

fitControl <- trainControl(method = "timeslice", horizon = 365, initialWindow = 365 * 
                             2, fixedWindow = F, skip = 2)


gbmFitTime <- train(MP25 ~ ., data = Train, method = "gbm", trControl = fitControl, 
                    verbose = FALSE)

postResample(pred = predict(gbmFitTime, Test), obs = Test$MP25)
G