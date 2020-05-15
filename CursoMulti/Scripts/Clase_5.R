library(caret)
library(tidyverse)
library(MuMIn)
library(broom)

Rs <- c(0.69, 0.53, 0.67, 0.54, 0.86)

## Primero seleccion de modelos en base a AICc

data("mtcars")

fit1 <- lm(mpg ~ hp, data = mtcars)
fit2 <- lm(mpg ~ hp + I(hp^2), data = mtcars)
fit3 <- lm(mpg ~ hp + I(hp^2) + I(hp^3), data = mtcars)
fit4 <- lm(mpg ~ hp + I(hp^2) + I(hp^3) + I(hp^4), data = mtcars)
fit5 <- lm(mpg ~ hp + I(hp^2) + I(hp^3) + I(hp^4) + I(hp^5), data = mtcars)
fit6 <- lm(mpg ~ hp + I(hp^2) + I(hp^3) + I(hp^4) + I(hp^5) + I(hp^6), data = mtcars)

models <- list(fit1, fit2, fit3, fit4, fit5, fit6)
SelectedMods <- model.sel(models)

### Usando caret y crossvalidation

# Par un solo modelo

set.seed(707)

ctrl <- trainControl(method = "repeatedcv", number = 5, repeats = 50)

DF <- train(mpg ~ hp, data = mtcars, method = "lm", trControl = ctrl)$resample

DF <- DF %>% select(Rsquared, Resample) %>% summarise_if(is.numeric, .f = c(mean, sd))

## Para varios modelos

form1 <- "mpg ~ hp"
form2 <- "mpg ~ hp + I(hp^2)"
form3 <- "mpg ~ hp + I(hp^2) + I(hp^3)"
form4 <- "mpg ~ hp + I(hp^2) + I(hp^3) + I(hp^4)"
form5 <- "mpg ~ hp + I(hp^2) + I(hp^3) + I(hp^4) + I(hp^5)"
form6 <- "mpg ~ hp + I(hp^2) + I(hp^3) + I(hp^4) + I(hp^5) + I(hp^6)"

forms <- list(form1, form2, form3, form4, form5, form6)
K = (2:7)

ctrl <- trainControl(method = "repeatedcv", number = 5, repeats = 50)


#### Tabla


set.seed(707)

Tests <- forms %>% 
  map(~train(as.formula(.x), data = mtcars, method = "gbm", trControl = ctrl)) %>% 
  map(~as.data.frame(.x$resample)) %>% 
  map(~select(.x, Rsquared)) %>% 
  map(~summarise_all(.x, .f = c(mean,sd), na.rm = T)) %>% 
  map2(.y = forms,~mutate(.x, model = .y)) %>% 
  reduce(bind_rows) %>% 
  rename(RsqMean = fn1, sd = fn2) %>% 
  mutate(K = K) %>% 
  arrange(desc(RsqMean))
