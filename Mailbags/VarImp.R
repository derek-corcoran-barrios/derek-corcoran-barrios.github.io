library(caret)
library(tidyverse)
library(broom)
## idea mas simple

ConHP <- lm(mpg ~ hp + wt + qsec, data = mtcars)
SinHP <- lm(mpg ~ wt + qsec, data = mtcars)

RSqCon <- glance(ConHP) %>% pull(r.squared)
RSqSin <- glance(SinHP) %>% pull(r.squared)

RSqCon - RSqSin

## Problema correlación

mtcars %>% dplyr::select(hp, wt, qsec) %>% cor()

## Suma de cuadrados

Fit1 <- lm(mpg ~ hp + wt + qsec, data = mtcars)

broom::tidy(anova(Fit1))

Fit2 <- lm(mpg ~wt + qsec + hp, data = mtcars)

# Orden importa

broom::tidy(anova(Fit1))
broom::tidy(anova(Fit2))

## Que parte del Rsquared

Totales_Sin_Resid <- broom::tidy(anova(Fit1)) %>% 
  dplyr::filter(term != "Residuals") %>% 
  summarise(sumsq = sum(sumsq))

Totales_Sin_Resid <- broom::tidy(anova(Fit2)) %>% 
  dplyr::filter(term != "Residuals") %>% 
  summarise(sumsq = sum(sumsq))

Totales_Con_Resid <- broom::tidy(anova(Fit1)) %>% 
  summarise(sumsq = sum(sumsq))

Totales_Sin_Resid/Totales_Con_Resid

Totales_hp_Resid1 <- broom::tidy(anova(Fit1)) %>% 
  dplyr::filter(term == "hp") %>% 
  summarise(sumsq = sum(sumsq))

Totales_hp_Resid2 <- broom::tidy(anova(Fit2)) %>% 
  dplyr::filter(term == "hp") %>% 
  summarise(sumsq = sum(sumsq))


Totales_hp_Resid1/Totales_Con_Resid
Totales_hp_Resid2/Totales_Con_Resid


broom::glance(Fit1)

## Todas las combinaciones
Variables <- c("hp", "qsec", "wt")

Todas_Las_Comb <- expand_grid(Var1 = Variables, Var2 = Variables, Var3 = Variables) %>% 
  dplyr::filter(Var1 != Var2 & Var1 != Var3 & Var2 != Var3) %>% 
  mutate(Model = paste(Var1, Var2, Var3, sep = "+"), Model = paste("mpg ~", Model))

Models <- list()

for(i in 1:nrow(Todas_Las_Comb)){
  Models[[i]] <- lm(as.formula(Todas_Las_Comb$Model[i]), data = mtcars) %>% 
    anova() %>% broom::tidy()
}

Models <- Models %>% 
  reduce(bind_rows) %>% 
  mutate(Cont = sumsq/Totales_Con_Resid$sumsq) %>% 
  dplyr::filter(term != "Residuals")


ggplot(Models, aes(x = term, y = Cont)) + 
  geom_boxplot() + 
  theme_bw()



### Paquete Importancia relativa

library(relaimpo)

relaimpo::calc.relimp(Fit1, type = "lmg")
relaimpo::calc.relimp(Fit1, type = "lmg")@lmg %>% sum()

relaimpo::calc.relimp(Fit1, type = "pratt")
