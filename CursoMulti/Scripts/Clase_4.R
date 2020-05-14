library(tidyverse)
library(MuMIn)
library(broom)
library(lme4)

## Cargando la base de datos

data("CO2")

ggplot(CO2, aes(x = conc, y = uptake, group = Plant)) + geom_line(aes(color = Type, lty = Treatment)) + geom_point(aes(color = Type)) + theme_bw()

#Modelo lineal simple
mod1 <- lm(uptake ~ Type * Treatment + I(log(conc)) + conc, data = CO2)

#Modelo lineal mixto

mod2 <- lmer(uptake ~ Type * Treatment + I(log(conc)) + conc + (1 | Plant), data = CO2)


# para que mumin no genere errores

options(na.action = "na.fail")

# para calcular el máximo de variables

Max.Vars <- floor(nrow(CO2)/10)

Seleccion <- dredge(mod2, m.lim = c(0, Max.Vars))

# Cargamos la base de datos cement

data("Cement")


# Generamos el modelo global

GlobalMod <- lm(y ~ ., data = Cement)


## Saco la primera columna por que es la que queremos explicar


smat <- abs(cor(Cement[, -1])) <= 0.7

smat[!lower.tri(smat)] <- NA

# Ahora hacemos la seleccion de modelos tomando en cuenta lo multicolinearidad

Selected <- dredge(GlobalMod, subset = smat)

Max.Vars <- floor(nrow(Cement)/10)

Selected <- dredge(GlobalMod, subset = smat, m.lim = c(0, Max.Vars))


ggplot(ChickWeight, aes(x = Time, y = weight, group = Chick)) + geom_line(aes(color = Diet)) + geom_point(aes(color = Diet)) + theme_bw()