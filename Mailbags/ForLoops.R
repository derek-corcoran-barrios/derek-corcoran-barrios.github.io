library(tidyverse)
library(broom)

x <- round(runif(35, max = 20))

Letras <- vector()
## For loops
for(n in 1:length(x)){
  Numero <- x[n] + 4
  Letras[n] <- letters[Numero]
}

data("CO2")
# parte de linea 16 y llega a la linea 30

Modelos <- c("uptake ~ Type", "uptake ~ Treatment", "uptake ~ conc", "uptake ~ Type + Treatment + conc", "uptake ~ Type + conc + I(log(conc))")

Fits <- list()

for(m in 1:length(Modelos)){
  Fits[[m]] <- lm(Modelos[m], data = CO2) %>% glance() %>% dplyr::select(r.squared, adj.r.squared, AIC) %>% mutate(Modelo = paste0("Fit", m), Formula = Modelos[m])
}

Fits <- bind_rows(Fits) %>% arrange(AIC)

##


Fit1 <- lm(uptake ~ Type, data = CO2)
Fit2 <- lm(uptake ~ Treatment, data = CO2)
Fit3 <- lm(uptake ~ conc, data = CO2)
Fit4 <- lm(uptake ~ Type + Treatment + conc, data = CO2)
Fit5 <- lm(uptake ~ Type + conc + I(log(conc)), data = CO2)

Modelo1 <- glance(Fit1) %>% dplyr::select(r.squared, adj.r.squared,AIC) %>% mutate(Modelo = "Fit1")
Modelo2 <- glance(Fit2) %>% dplyr::select(r.squared, adj.r.squared, AIC) %>% mutate(Modelo = "Fit2")
Modelo3 <- glance(Fit3) %>% dplyr::select(r.squared, adj.r.squared, AIC) %>% mutate(Modelo = "Fit3")
Modelo4 <- glance(Fit4) %>% dplyr::select(r.squared, adj.r.squared,AIC) %>% mutate(Modelo = "Fit4")
Modelo5 <- glance(Fit5) %>% dplyr::select(r.squared, adj.r.squared,AIC) %>% mutate(Modelo = "Fit5")

Modelos <- bind_rows(Modelo1, Modelo2, Modelo3, Modelo4,Modelo5) %>% 
  arrange(AIC) %>% mutate(DeltaAIC = AIC - min(AIC))