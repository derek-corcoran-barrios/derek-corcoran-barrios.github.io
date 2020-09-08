library(tidyverse)
library(broom)

# Abrir base de datos

data("CO2")

View(CO2)


### Modelo linal

# Captación de CO2 explicado por ecotipo

Fit1 <- lm(uptake ~ Type, data = CO2)

## Para el modelo general

Est1 <- glance(Fit1)

Est2 <- tidy(Fit1)

Est3 <- augment(Fit1)


### Comparación de modelos

Fit1 <- lm(uptake ~ Type, data = CO2)
Fit2 <- lm(uptake ~ Treatment, data = CO2)
Fit3 <- lm(uptake ~ conc, data = CO2)
Fit4 <- lm(uptake ~ Type + Treatment + conc, data = CO2)
Fit5 <- lm(uptake ~ Type + conc + I(log(conc)), data = CO2)
Fit6 <- lm(uptake ~ Type + I(log(conc)), data = CO2)
Fit7 <- lm(uptake ~ Type:Treatment + conc + I(log(conc)), data = CO2)

Aug5 <- augment(Fit5) %>% full_join(CO2)
Aug6 <- augment(Fit6) %>% full_join(CO2)


ggplot(Aug5, aes(x = conc, y = .fitted)) + geom_line(aes(lty = Treatment, color = Type))

ggplot(Aug6, aes(x = conc, y = .fitted)) + geom_line(aes(lty = Treatment, color = Type))



Modelo1 <- glance(Fit1) %>% dplyr::select(r.squared,AIC) %>% mutate(Modelo = "Fit1")
Modelo2 <- glance(Fit2) %>% dplyr::select(r.squared,AIC) %>% mutate(Modelo = "Fit2")
Modelo3 <- glance(Fit3) %>% dplyr::select(r.squared,AIC) %>% mutate(Modelo = "Fit3")
Modelo4 <- glance(Fit4) %>% dplyr::select(r.squared,AIC) %>% mutate(Modelo = "Fit4")
Modelo5 <- glance(Fit5) %>% dplyr::select(r.squared,AIC) %>% mutate(Modelo = "Fit5")
Modelo6 <- glance(Fit6) %>% dplyr::select(r.squared,AIC) %>% mutate(Modelo = "Fit6")
Modelo7 <- glance(Fit7) %>% dplyr::select(r.squared,AIC) %>% mutate(Modelo = "Fit7")

Modelos <- bind_rows(Modelo1, Modelo2, Modelo3, Modelo4,Modelo5, Modelo6, Modelo7) %>% 
  arrange(AIC) %>% mutate(Delta_AIC = AIC - min(AIC))


### Metemos todas las variables de una


ggplot(CO2, aes(x = conc, y = uptake, group = Plant)) +
  geom_point(aes(color = Type, shape = Treatment)) +
  geom_line(aes(color = Type, lty = Treatment)) +
  theme_bw()

