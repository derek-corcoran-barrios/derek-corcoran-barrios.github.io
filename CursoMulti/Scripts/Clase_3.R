# Cargamos paquetes

library(MuMIn)
library(broom)
library(tidyverse)

# Cargamos base de datos

data("ChickWeight")

## Ajustamos el primer modelo

fit1 <- lm(weight ~ Time + Diet, data = ChickWeight)

fit2 <- lm(weight ~ Time + Time:Diet, data = ChickWeight)

fit3 <- lm(weight ~ Time * Diet, data = ChickWeight)



DF <- ChickWeight


DF$Pred <-  predict(fit2, newdata = DF)


## Seleccion de modelos

Select <- MuMIn::model.sel(list(fit1, fit2, fit3))



#### Nuevos fit


  extending the linear model with-r
  
  faraway
  
  R
  
  Crawley
  
    

fit2g <- glm(weight ~ Time + Time:Diet, Gamma, data = ChickWeight)

fit2p <- glm(weight ~ Time + Time:Diet, poisson, data = ChickWeight)


####
train <- read_csv("https://raw.githubusercontent.com/derek-corcoran-barrios/derek-corcoran-barrios.github.io/master/CursoMultiPres/Capitulo_3/train.csv") %>% 
  filter(Embarked == "S")
