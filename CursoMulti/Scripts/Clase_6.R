## Primer caso clasificación

library(tidyverse)
library(caret)
library(MuMIn)

data(iris)

## Generar bases de datos de entrenamiento y de prueba

set.seed(707)

Index <- createDataPartition(iris$Species, list = FALSE, p = 0.5)
Train <- iris[Index, ]
Test <- iris[-Index, ]


fitControl <- trainControl(method = "repeatedcv", number = 10, repeats = 10)

## Entrenamos nuestro modelo

Class <- train(Species ~ ., data = Train, method = "rpart", trControl = fitControl)

postResample(pred = predict(Class, Train), obs = Train$Species)
postResample(pred = predict(Class, Test), obs = Test$Species)

rpartGrid <- expand.grid(cp = c(0.48, 0.8, 1))
Class2 <- train(Species ~ ., data = Train, method = "rpart", trControl = fitControl, 
                tuneGrid = rpartGrid)
plot(Class2)


### Regresion con raster

library(raster)

githubURL <- ("https://raw.githubusercontent.com/derek-corcoran-barrios/derek-corcoran-barrios.github.io/master/CursoMultiPres/Capitulo_6/SA.rds")
download.file(githubURL, "SA.rds", method = "curl")
SA <- readRDS("SA.rds")

githubURL <- ("https://raw.githubusercontent.com/derek-corcoran-barrios/derek-corcoran-barrios.github.io/master/CursoMultiPres/Capitulo_6/sp2.rds")
download.file(githubURL, "sp2.rds", method = "curl")
sp2 <- read_rds("sp2.rds")

githubURL <- ("https://raw.githubusercontent.com/derek-corcoran-barrios/derek-corcoran-barrios.github.io/master/CursoMultiPres/Capitulo_6/sp.rds")
download.file(githubURL, "sp.rds", method = "curl")
sp <- read_rds("sp.rds")


#####

set.seed(707)
Index1 <- createDataPartition(sp2$presence, list = FALSE, p = 0.8)
Train1 <- sp2[Index1, ]
Test1 <- sp2[-Index1, ]

#### Train

fitControl <- trainControl(method = "repeatedcv", number = 10, repeats = 10)
set.seed(707)
Model <- train(presence ~ ., data = Train1, method = "rpart", trControl = fitControl)


caret::postResample(pred = predict(Model, Test1), obs = Test1$presence)

library(raster)
Map <- predict(SA, Model)

plot(Map)


set.seed(707)
Model2 <- train(presence ~ ., data = Train1, method = "gbm", trControl = fitControl)


set.seed(707)
Model3 <- train(presence ~ ., data = Train1, method = "rf", trControl = fitControl)


#### Comparacion entre algoritmos

Comp <- resamples(list(Rpart = Model, GBM = Model2, RF = Model3))
Difs <- diff(Comp)

densityplot(Difs, metric = "Rsquared", auto.key = TRUE, pch = "|")
### Predecimos mapas para estos dos algoritmos

Map2 <- predict(SA, Model2)
Map3 <- predict(SA, Model3)


#### En base a glm

FitGlob <- glm(presence ~ ., family = binomial, data = sp2)
library(MuMIn)
smat <- abs(cor(sp2[, -1])) <= 0.7
smat[!lower.tri(smat)] <- NA

K = floor(nrow(sp2)/10)
options(na.action = "na.fail")
Selected <- dredge(FitGlob, subset = smat, m.lim = c(0, K))


best <- get.models(Selected, subset = delta < 2)
best <- best[[1]]
library(raster)
MapLM <- predict(SA, best, type = "response")
