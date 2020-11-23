library(tidyverse)
library(broom)

githubURL <- ("https://raw.githubusercontent.com/Curso-programacion/Datos_Arboles/master/Data.rds")
download.file(githubURL, "Data.rds", method = "curl")
Data <- read_rds("Data.rds")

### 

Modelo <- lm(Altura ~ DAP, data = Data)

Parametros <- tidy(Modelo)

## Graficamos el modelo lineal

ggplot(Data, aes(y = Altura, x = DAP)) + geom_point() + 
  geom_smooth(method = "lm") + theme_bw()


DF <- data.frame(DAP = c(50, 36, 20, 80, 100))



DF$Pred <- predict(Modelo, newdata = DF)


Predicciones <- predict(Modelo, newdata = DF, se.fit = T)

DF$Error <- Predicciones$se.fit

## Varianza explicada

Explicado <- glance(Modelo)


Residuales_Otros <- augment(Modelo)


## Modelo2 

Modelo2 <- lm(Altura ~ DAP + Familia, data = Data)

Parametros2 <- tidy(Modelo2)
Explicado2 <- glance(Modelo2)


### Temperatura y humedad

githubURL <- ("https://raw.githubusercontent.com/derek-corcoran-barrios/derek-corcoran-barrios.github.io/master/Clase4/TempHum.rds")
download.file(githubURL, "TempHum.rds", method = "curl")

TempHum <- read_rds("TempHum.rds") %>% 
  mutate(Mes = as.numeric(Mes))

VA <- TempHum %>% dplyr::filter(Ciudad_localidad == "Valdivia")

ggplot(TempHum, aes(x = Mes, y = Temperatura)) + 
  geom_point() +
  facet_wrap(~Ciudad_localidad)

ggplot(VA, aes(x = Mes, y = Temperatura)) + 
  geom_point() +
  geom_smooth(method = "lm") +
  facet_wrap(~Ciudad_localidad)


ModeloTemp <- lm(Temperatura ~ Mes, data = VA)

ModeloTempCuad <- lm(Temperatura ~ Mes + I(Mes^2), data = VA)


ggplot(VA, aes(x = Mes, y = Temperatura)) + 
  geom_point() +
  stat_smooth(method = "lm", formula = y ~x + I(x^2)) +
  facet_wrap(~Ciudad_localidad)


DF <- data.frame(Mes = 1:12)


predict(ModeloTempCuad, newdata = DF)


Coy <- TempHum %>% 
  dplyr::filter(Ciudad_localidad == "Coyhaique") %>% 
  pivot_longer(cols = c("Temperatura", "Humedad"), names_to = "Variable", values_to = "Valor")

ggplot(Coy, aes(x = Mes, y = Valor)) + 
  geom_point(aes(color = Variable)) +
  stat_smooth(method = "lm", formula = y ~x + I(x^2), aes(color = Variable)) +
  facet_wrap(~Ciudad_localidad)

TempHum <- read_rds("TempHum.rds") %>% 
  mutate(Mes = as.numeric(Mes)) %>% 
  pivot_longer(cols = c("Temperatura", "Humedad"), names_to = "Variable", values_to = "Valor")

ggplot(TempHum, aes(x = Mes, y = Valor)) + 
  geom_point(aes(color = Variable)) +
  stat_smooth(method = "lm", formula = y ~x + I(x^2), aes(color = Variable)) +
  facet_wrap(~Ciudad_localidad)


### Formas

TempHum <- read_rds("TempHum.rds") %>% 
  mutate(Mes = as.numeric(Mes))

Coy <- TempHum %>% 
  dplyr::filter(Ciudad_localidad == "Coyhaique")

ggplot(Coy, aes(x = Mes, y = Temperatura)) + 
  geom_point() +
  stat_smooth(method = "lm", formula = y ~x + I(x^2)) +
  facet_wrap(~Ciudad_localidad)
