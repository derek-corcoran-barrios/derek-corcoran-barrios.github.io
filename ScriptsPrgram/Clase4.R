library(tidyverse)

#descarga de datos y lectura

githubURL <- ("https://raw.githubusercontent.com/Curso-programacion/Tarea_1/master/Protected_Areas.rds")
download.file(githubURL, "PA.rds", method = "curl")

PA <- readRDS("PA.rds") %>% mutate(LogArea = log(TERR_AREA))


### Vamos a graficar

ggplot(PA, aes(x = STATUS_YR, y = TERR_AREA)) +
  geom_point(aes(color = DESIG)) +
  theme_bw() + scale_y_continuous(labels = scales::comma)

ggplot(PA, aes(x = STATUS_YR, y = TERR_AREA)) +
  geom_point(aes(shape = IUCN_CAT, color = IUCN_CAT)) +
  theme_bw() + 
  scale_y_log10(labels = scales::comma) +
  labs(x = "Año", y = "Área en hectáreas", title = "Áreas protegidas de Chile")


###
data("iris")

ggplot(iris, aes(x = Species, y = Sepal.Length)) + 
  geom_violin(aes(fill = Species)) + 
   geom_jitter() +
   scale_fill_manual(values = c('#fc8d59','#ffffbf','#99d594')) +
  theme_bw()


ggplot(iris, aes(x = fct_reorder(Species, Sepal.Width), y = Sepal.Width)) +
  geom_boxplot(notch = T, aes(fill = Species))+
    theme_bw() 


ggplot(PA, aes(x = fct_reorder(IUCN_CAT,TERR_AREA, .fun = max), y = TERR_AREA)) +
  geom_boxplot(notch = T, aes(fill = IUCN_CAT))+
  theme_bw() + scale_y_log10(labels = scales::comma, breaks = c(1,10,100,1000000))

### alpha

data("diamonds")

ggplot(diamonds, aes(x = carat, y = price)) +
  geom_point(aes(color = cut), alpha = 0.2)

## Size

data("mtcars")

ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point(aes(size = hp), color = "#325e10")



ggplot(PA, aes(x = STATUS_YR, y = TERR_AREA)) +
  geom_point(aes(color = IUCN_CAT)) +
  theme_bw() + 
  scale_y_log10(labels = scales::comma) +
  labs(x = "Año", y = "Área en hectáreas", title = "Áreas protegidas de Chile") +
  facet_wrap(~SUB_LOC)

PA <- PA %>% mutate(SUB_LOC = fct_relevel(SUB_LOC, "Los Ríos", "Los Lagos", "Magallanes"))

ggplot(PA, aes(x = STATUS_YR, y = TERR_AREA)) +
  geom_point(aes(color = IUCN_CAT)) +
  theme_bw() + 
  scale_y_log10(labels = scales::comma) +
  labs(x = "Año", y = "Área en hectáreas", title = "Áreas protegidas de Chile") +
  facet_wrap(~SUB_LOC)


mt <- mtcars %>% mutate(cyl = as.factor(cyl), am = as.factor(am))

ggplot(mt, aes(x = wt, y = mpg)) + 
  geom_point() + 
  geom_smooth(method = "lm") +
  facet_grid(cyl~am)

