library(tidyverse)

Contagiados <- read_csv("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto19/CasosActivosPorComuna.csv")


Contagiados2 <- Contagiados %>% 
  pivot_longer(cols = starts_with("2020"),
               names_to = "Fecha",
               values_to = "Infectados"
               ) %>% 
  mutate(Fecha = lubridate::ymd(Fecha), prevalencia = 100000*(Infectados/Poblacion)) %>% 
  dplyr::filter(Fecha == max(Fecha), !is.na(`Codigo comuna`)) %>%
  arrange(desc(prevalencia))

# Pivot_wider
data(fish_encounters)

Para_captura <-  fish_encounters %>%  
  pivot_wider(names_from = "station",
            values_from = "seen",
            values_fill = 0)


data(warpbreaks)

Breaks <- warpbreaks %>% 
  pivot_wider(names_from = tension, 
              values_from = breaks,
              values_fn = mean) %>% 
  summarise_if(is.numeric, ~round(.x, 2))


### Join

Episodes <- read_csv("https://raw.githubusercontent.com/derek-corcoran-barrios/The_office/master/The_Office_Episodes_per_Character.csv")

words <- read_csv("https://raw.githubusercontent.com/derek-corcoran-barrios/The_office/master/The_office_Words.csv")

stop_words <- read_csv("https://raw.githubusercontent.com/derek-corcoran-barrios/The_office/master/stop_words.csv")

## Full Join

Episodios_words <- full_join(Episodes, words)


##

Episodes_top_10_words <- Episodes %>% 
  slice_max(order_by = n_episodes, n = 10) %>% 
  left_join(words)

##Palabras mas usadas
Top_Words <- Episodes_top_10_words %>%
  anti_join(stop_words) %>% 
  group_by(word) %>% 
  summarise(n = n()) %>%
  ungroup() %>% 
  slice_max(order_by = n, n = 20)
  
##Palabras mas usadas por personaje

Top_Words <- Episodes_top_10_words %>%
  anti_join(stop_words) %>% 
  group_by(word, speaker) %>% 
  summarise(n = n()) %>%
  ungroup() %>% 
  group_by(speaker)%>% 
  slice_max(order_by = n, n = 10)



