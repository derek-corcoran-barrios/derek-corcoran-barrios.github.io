library(tidyverse)
library(broom.mixed)
library(lme4)

data("CO2")

ggplot(CO2, aes(x = conc, y = uptake, color = Type)) +
  geom_point(aes(shape = Treatment)) +
  geom_path(aes(group = Plant, lty = Treatment)) + 
  theme_bw()


Fit1 <- lm(uptake ~ I(log(conc)) + Type:Treatment, data = CO2)

Fit2 <- lmer(uptake ~ I(log(conc)) + Type:Treatment + (1 | Plant), data = CO2)


broom::glance(Fit1)
broom::tidy(Fit1)


broom.mixed::glance(Fit2)
broom.mixed::tidy(Fit2)

data("ChickWeight")

ggplot(ChickWeight, aes(x = Time, y = weight)) + 
  geom_point(aes(color = Diet)) +
  geom_path(aes(color = Diet, group = Chick))

Fit1_Poisson <- glm(weight ~ Diet:Time, data =ChickWeight, family = poisson)

Fit2_Poisson <- glmer(weight ~ Diet:Time + (1|Chick), data =ChickWeight, family = poisson)


broom::tidy(Fit1_Poisson)
broom.mixed::tidy(Fit2_Poisson)

sjPlot::plot_model(Fit1_Poisson,type = "eff")

