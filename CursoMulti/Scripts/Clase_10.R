library(caret)
library(tidyverse)

Train <- read_csv("Train.csv") %>% arrange(Fecha)


fitControl <- trainControl(method = "timeslice", horizon = 346*3, 
                           initialWindow = 346 * 3, fixedWindow = T, skip = 346)


gbmFitTime <- train(Activos_5_por_100.000 ~ ., 
                     data = Train, 
                     method = "gbm", 
                     trControl = fitControl, 
                     verbose = FALSE)


plot(gbmFitTime)

### Cambiar el grid

Combinaciones <- expand.grid(Letras = c("a", "b", "c"),
                            Numeros = c(1,2,3,4))


gbmGrid <-  expand.grid(interaction.depth = c(1, 5, 9), 
                        n.trees = (1:30)*50, 
                        shrinkage = c(0.1, 0.01),
                        n.minobsinnode = c(10, 30))




library(doParallel)

parallel::detectCores()

cl <- makePSOCKcluster(4)

registerDoParallel(cl)


gbmFitTime1 <- train(Activos_5_por_100.000 ~ ., data = Train, 
                 method = "gbm", 
                 trControl = fitControl, 
                 verbose = FALSE, 
                 tuneGrid = gbmGrid)


stopCluster(cl)

plot(gbmFitTime1)
  

