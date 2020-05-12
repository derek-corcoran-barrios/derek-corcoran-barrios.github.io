## Clase 1

library(tidyverse)
library(MuMIn)
library(caret)
library(broom)

data("mtcars")

set.seed(2020)


index <- sample(1:nrow(mtcars), size = round(nrow(mtcars)/2))

#Base de datos de entrenamiento

Train <- mtcars[index,]

#Base de datos de prueba

Test <- mtcars[-index,]

# Ajustar el modelo

Modelo <- lm(mpg ~ hp + I(hp^2), data = Train)

broom::tidy(Modelo)
broom::glance(Modelo)

## Hacemos una predicción en la base de datos nueva

Test$Pred <- predict(Modelo, newdata = Test)

Train$Pred <- predict(Modelo, newdata = Train)


ggplot(Test, aes(x = hp, y = mpg)) + geom_point() + geom_line(aes(y = Pred)) + theme_bw()

## Poder predictivo vs explicativo

postResample(pred = Train$Pred, obs = Train$mpg)

postResample(pred = Test$Pred, obs = Test$mpg)

## Soluciones para el ejecicio

DF <- tibble(Formula = NA, Model = NA, K = NA, R_2_Train = NA, 
             R_2_Test = NA, AICc = NA)

DF$Formula <- "mpg ~ hp + wt"

DF$Model <- lm(as.formula(DF$Formula), data =Train) %>% list()


DF$R_2_Train <- DF$Model[[1]] %>% glance() %>% pull(r.squared)

DF$K <- DF$Model[[1]] %>% glance() %>% pull(df)

DF$AICc <- DF$Model[[1]] %>% AICc

DF$R_2_Test <- postResample(pred = predict(DF$Model[[1]], Test), obs = Test$mpg)[2]


##Modelo2

DF2 <- tibble(Formula = NA, Model = NA, K = NA, R_2_Train = NA, 
             R_2_Test = NA, AICc = NA)

DF2$Formula <- "mpg ~ wt"

DF2$Model <- lm(as.formula(DF2$Formula), data =Train) %>% list()


DF2$R_2_Train <- DF2$Model[[1]] %>% glance() %>% pull(r.squared)

DF2$K <- DF2$Model[[1]] %>% glance() %>% pull(df)

DF2$AICc <- DF2$Model[[1]] %>% AICc

DF2$R_2_Test <- postResample(pred = predict(DF2$Model[[1]], Test), obs = Test$mpg)[2]


DF <- bind_rows(DF, DF2)

## Solucion 2

DF <- tibble(Formula = rep(NA, 4), Model = rep(NA, 
                                               4), K = rep(NA, 4), R_2_Train = rep(NA, 4), R_2_Test = rep(NA, 
                                                                                                          4), AICc = rep(NA, 4))




DF$Formula <- c("mpg ~ hp + wt", "mpg ~ hp + disp", 
                "mpg ~ wt + disp", "mpg ~ wt")


for(i in 1:nrow(DF)){
  DF$Model[i] <- lm(as.formula(DF$Formula[i]), data = mtcars) %>% list()
  DF$R_2_Train[i] <- DF$Model[i][[1]] %>% glance() %>% pull(r.squared)
  DF$K[i] <- DF$Model[i][[1]] %>% glance() %>% pull(df)
  DF$AICc[i] <- DF$Model[i][[1]] %>% AICc
  DF$R_2_Test[i] <- postResample(pred = predict(DF$Model[i][[1]], Test), obs = Test$mpg)[2]
}

## Solucion 3

Data <- list()
for (i in c(1:12)) {
  Data[[i]] <- tibble(Formula = purrr::map(as.data.frame(combn(c("cyl", 
                                                                 "disp", "hp", "drat", "wt", "qsec", "vs", "am", 
                                                                 "gear", "carb", "I(wt^2)", "I(hp^2)"), i)), 
                                           ~paste(.x, collapse = "+")) %>% reduce(c), 
                      Model = purrr::map(as.data.frame(combn(c("cyl", 
                                                               "disp", "hp", "drat", "wt", "qsec", "vs", 
                                                               "am", "gear", "carb", "I(wt^2)", "I(hp^2)"), 
                                                             i)), ~paste(.x, collapse = "+")) %>% purrr::map(~paste("mpg ~", 
                                                                                                                    .x)) %>% purrr::map(as.formula) %>% purrr::map(~lm(.x, 
                                                                                                                                                                       data = Train)), K = i + 1)
}
Data <- bind_rows(Data)


Data$R_2_Train <- NA
Data$R_2_Test <- NA
Data$AICc <- NA
for (i in 1:nrow(Data)) {
  Data$R_2_Train[i] <- R2(pred = predict(Data$Model[i][[1]], 
                                         Train), obs = Train$mpg)
  Data$R_2_Test[i] <- R2(pred = predict(Data$Model[i][[1]], 
                                        Test), obs = Test$mpg)
  Data$AICc[i] <- AICc(Data$Model[i][[1]])
}
Data <- Data %>% dplyr::select(-Model) %>% arrange(AICc)