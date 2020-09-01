## Caragar la base de datos

library(tidyverse)
data("diamonds")

ggplot(diamonds, aes(x = carat, y = price)) +
  geom_point(aes(color = cut), alpha = 0.2) +
  theme_bw()

### Para mtcars vamos a cambiar el tamaño

ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point(aes(size = hp, shape = hp )) + 
  theme_classic() + scale_shape_binned()

ggplot(diamonds, aes(x = carat, y = price)) + 
  geom_point(aes(shape = cut, color = color)) + 
  theme_classic()

## Boxplots

ggplot(iris, aes(x = Species, y = Sepal.Width)) +
  geom_boxplot(notch = T, aes(fill = Species)) +
  scale_fill_manual(name = "Especie",values = c('#a6cee3','#1f78b4','#b2df8a'))

ggplot(iris, aes(x = Species, y = Sepal.Width)) +
  geom_boxplot(notch = T, aes(fill = Species)) +
  scale_fill_viridis_d(name = "Especie")

ggplot(iris, aes(x = Species, y = Sepal.Width)) + 
  geom_jitter(aes(shape = Species))

ggplot(iris, aes(x = Species, y = Sepal.Width)) + 
  geom_violin(fill = '#a6cee3') + 
  coord_flip()

ggplot(iris, aes(x = Species, y = Sepal.Width)) + 
  geom_boxplot() + 
  geom_jitter(aes(color = Species))

### Así el boxplot tapa el

ggplot(iris, aes(x = Species, y = Sepal.Width)) + 
  geom_jitter(aes(color = Species)) +
  geom_boxplot()
  

ggplot(iris, aes(x = fct_reorder(Species, Sepal.Width), y = Sepal.Width)) + 
  geom_boxplot(notch = T) +
  xlab("Especie") + ylab("Ancho Sépalo")


ggplot(diamonds, aes(carat, price)) + geom_hex() + 
  scale_fill_viridis_c()

data("mtcars")
ggplot(mtcars, aes(x = hp, y = mpg)) +
  geom_smooth(method = "lm", fill = "red", alpha = 0.5) +
  geom_point()

### Con esto vamos a descargar una base de datos

githubURL <- ("https://raw.githubusercontent.com/derek-corcoran-barrios/derek-corcoran-barrios.github.io/master/Clase4/TempHum.rds")
download.file(githubURL, "TempHum.rds", method = "curl")
TempHum <- read_rds("TempHum.rds") %>% 
  mutate(Mes = as.numeric(Mes))


Valpo <- TempHum %>% filter(Ciudad_localidad == "Valparaíso")  
 

ggplot(Valpo, aes(x =  Mes, y = Temperatura)) +
  geom_point() +
  stat_smooth(method = "lm", formula = y ~ x + I(x^2))

Valpo2 <- Valpo %>% 
  pivot_longer(cols = c("Temperatura", "Humedad"), names_to = "Unidad", values_to = "Medida")

ggplot(Valpo2, aes(x =  Mes, y = Medida)) +
  geom_point(aes(color = Unidad)) +
  stat_smooth(method = "lm", formula = y ~ x + I(x^2), aes(fill = Unidad))
  

Algunos <- TempHum %>% filter(Ciudad_localidad %in% 
                                c("Arica", "Rapa Nui", "La Serena", "Valparaíso", 
                                  "Quinta Normal", "Concepción", "Valdivia", 
                                  "Punta Arenas"))



ggplot(Algunos, aes(x =  Mes, y = Temperatura)) +
  geom_point() +
  stat_smooth(method = "lm", formula = y ~ x + I(x^2)) +
  facet_wrap(~fct_reorder(Ciudad_localidad, Temperatura), ncol = 2)
