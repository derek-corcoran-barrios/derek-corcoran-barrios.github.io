library(tidyverse)
data("CO2")


ggplot(CO2, aes(x = conc, y = uptake)) + geom_point(aes(color = Type, shape = Treatment)) + stat_smooth(method = "lm", formula = "y ~ log(x) + x", aes(fill = Type, lty = Treatment, color = Type)) + theme_bw()


ggplot(CO2, aes(x = conc, y = uptake)) + geom_point(aes(color = Type, shape = Treatment)) + stat_smooth(method = "nls", formula = y ~ SSasymp(x, Asym, R0, lrc), se = F, aes(fill = Type, lty = Treatment, color = Type)) + theme_bw()


ggplot(CO2, aes(x = conc, y = uptake)) + geom_point(aes(color = Type, shape = Treatment)) + stat_smooth(method = "nls", formula = y ~ SSasymp(x, Asym, R0, lrc), se = F, aes(fill = Type, lty = Treatment, color = Type)) + theme_bw()


ggplot(ChickWeight, aes(x = Time, y = weight)) + geom_point(aes(color = Diet)) +  geom_smooth(method = "glm", method.args = list(family = "poisson"), formula = "y ~x", aes(fill = Diet, color = Diet))



Model <- glm(weight ~ Time + Time:Diet + Time^2, data = ChickWeight, family = poisson)

ggplot(ChickWeight, aes(x = Time, y = weight)) + geom_point(aes(color = Diet)) +  geom_smooth(mapping=aes(y=predict(Model,ChickWeight, type = "response"), color = Diet), se = T) 




