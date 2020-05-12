# Cargamos los paquetes

library(MuMIn)
library(broom)
library(tidyverse)

# Cargar nuestra base de datos

data("mtcars")

fit1 <- lm(mpg ~ carb + cyl, data = mtcars)
fit2 <- lm(mpg ~ cyl + wt, data = mtcars)
fit3 <- lm(mpg ~ am + qsec + wt, data = mtcars)
fit4 <- lm(mpg ~ carb + cyl + wt, data = mtcars)
fit5 <- lm(mpg ~ am + carb + cyl + qsec + wt, data = mtcars)
fit6 <- lm(mpg ~ am + carb + cyl + hp + qsec, data = mtcars)

## Metemos todos estos modelos en una lista

models <- list(fit1, fit2, fit3, fit4, fit5, fit6)

### Tabla de selección

Select <- model.sel(models)

Selected <- subset(Select, delta <= 2)

## Obtenemos el mejor modelo

BestModel <- get.models(Select, 1)[[1]]

# Generar un dataframe con las variables que vamos a promdiar

S <- as.data.frame(Selected)
S <- as.data.frame(Selected) %>% select(cyl, weight)

### Primero en el metodo full
S_full <- S
S_full$cyl <- ifelse(is.na(S_full$cyl), 0, S_full$cyl)
S_full <- S_full %>% mutate(Theta_i = cyl * weight)

# Calculo final

Cyl_hat <- sum(S_full$Theta_i)

## Metodo subset

S_sub <- S %>% filter(!is.na(cyl))
S_sub <- S_sub %>% mutate(Theta_i = cyl * weight)

Cyl_hat <- sum(S_sub$Theta_i)/sum(S_sub$weight)


### AHora con MuMIn

AverageModel <- model.avg(Select, subset = delta < 2, fit = T)

#############################################################
#############################################################

#Multicolinearidad

library(readr)
bloodpress <- read_delim("https://online.stat.psu.edu/onlinecourses/sites/stat501/files/data/bloodpress.txt", 
                         "\t", escape_double = FALSE, col_types = cols(Pt = col_skip()), trim_ws = TRUE)
