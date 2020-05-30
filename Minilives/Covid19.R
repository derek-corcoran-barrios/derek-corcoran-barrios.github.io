library(tidyverse)
library(gganimate)
library(ggrepel)
# Producto 19

Activos <- read_csv("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto19/CasosActivosPorComuna.csv")

Activos <- Activos %>% pivot_longer(starts_with("2020"), names_to = "Fecha", values_to = "Infectados") %>% 
           mutate(Fecha = lubridate::ymd(Fecha)) %>% 
           dplyr::filter(Comuna != "Total") %>% 
           mutate(Infectados_por_100.000 = (Infectados/Poblacion)*100000) %>% 
           dplyr::filter(Region %in% c("Valparaiso", "Antofagasta", "Biobio"))


ggplot(Activos, aes(x = Fecha, y = Infectados_por_100.000)) + geom_line(aes(color = Comuna)) + facet_wrap(~Region) + geom_hline(yintercept = 40, lty= 2, color = "red") + geom_point() +  transition_reveal(along = Activos$Fecha) + geom_text_repel(aes(label = Comuna)) + theme_bw()+ theme(legend.position = "none")

# Producto 7

#Producto 1

