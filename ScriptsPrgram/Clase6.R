library(tidyverse)
library(broom)

data("mtcars")

Modelo <- lm(mpg ~ wt, data = mtcars)

tidy(Modelo)

Modelo2 <- lm(mpg ~ wt + hp, data = mtcars)

tidy(Modelo2)
37.3 -5.38*3

37.2 -3.88*3 -0.03*150

### Categorica

mt <- mtcars %>% mutate(am = ifelse(am == 0, "automatico", "manual"))

Dummy <- mt %>% 
  dplyr::select(mpg, am) %>% 
  mutate(automatico = ifelse(am == "automatico", 1, 0),
                       manual = ifelse(am == "manual", 1, 0))

Modelo3 <- lm(mpg ~ am, data = mt)

Modelo4 <- lm(mpg ~ wt + am, data = mt)

ggplot(data = mt, aes(x = wt, y = mpg)) + geom_point(aes(color = am))

## Ejemplo pollos

data("ChickWeight")

Fit1 <- lm(weight ~ Time + Diet, data = ChickWeight) 

Fit2 <- lm(weight ~ Time + Time:Diet, data = ChickWeight)

Fit2b <- lm(weight ~ Time:Diet, data = ChickWeight)

Fit3a <- lm(weight ~ Time + Diet + Time:Diet, data = ChickWeight)
Fit3b <- lm(weight ~ Time*Diet, data = ChickWeight) 


### Resiudales

Residuales2 <- augment(Fit2)


ggplot(data = Residuales2, aes(x = .fitted, y = .resid)) + 
  geom_point() + geom_hline(lty = 2, yintercept = 0, color = "red") + theme_bw()


## Datos CO2

data(CO2)

Modelo <- lm(uptake ~ conc + I(log(conc)) + Type*Treatment, data = CO2)


### Prediccion

NewDf <- CO2 %>% dplyr::select(-Plant) %>% distinct()

NewDf$Pred <- predict(Modelo, newdata = NewDf)

Predictciones <- predict(Modelo, newdata = NewDf, se.fit = T)


NewDf$se <- Predictciones$se.fit

ggplot(NewDf, aes(x = conc, y = Pred)) + geom_path(aes(color = Type, shape = Treatment, group = interaction(Treatment, Type)))
