library(tidyverse)

Episodes <- read_csv("https://raw.githubusercontent.com/derek-corcoran-barrios/The_office/master/The_Office_Episodes_per_Character.csv")

words <- read_csv("https://raw.githubusercontent.com/derek-corcoran-barrios/The_office/master/The_office_Words.csv")

stop_words <- read_csv("https://raw.githubusercontent.com/derek-corcoran-barrios/The_office/master/stop_words.csv")



Presonajes_por_temp <- words  %>% 
  group_by(speaker, season) %>% 
  summarise(n = n()) %>% 
  ungroup()%>% 
  group_by(season) %>% 
  slice_max(order_by = n, n = 10) %>% 
  ungroup() %>% 
  arrange(season, desc(n))

Presonajes_por_temp <- Presonajes_por_temp %>% dplyr::select(speaker) %>% distinct()

Eps_Per_Season <- words %>% 
  dplyr::select(season, episode) %>% 
  distinct() %>% 
  group_by(season) %>% 
  summarise(Eps = n())

Palabras_por_Temp <- 
  Presonajes_por_temp %>% 
  left_join(words) %>% 
  group_by(speaker, season) %>% 
  summarise(n = n()) %>% 
  ungroup() %>% 
  pivot_wider(names_from = speaker, values_from = n, values_fill = 0) %>% 
  pivot_longer(cols = Andy:Toby, names_to = "speaker", values_to = "words") %>% 
  arrange(season) %>% 
  left_join(Eps_Per_Season) %>% 
  group_by(speaker) %>% 
  mutate(words = words/Eps, Lag = lag(words), delta = words-Lag) %>% 
  dplyr::filter(!is.na(delta))


G <-ggplot(Palabras_por_Temp, aes(x = season, y = delta)) + 
  geom_path(aes(color = speaker)) + 
  theme(legend.position = "bottom")


plotly::ggplotly(G)
