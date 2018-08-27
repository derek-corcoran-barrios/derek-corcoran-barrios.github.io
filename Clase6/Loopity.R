### Sin loop

library(tidyverse)
library(lubridate)

stations <- read_csv("Clase6/stations.csv") %>% rename(station = id)
Madrid2017 <- read_csv("Clase6/csvs_per_year/madrid_2017.csv") %>% filter(station %in% c(28079036, 28079008,28079058, 28079060, 28079038)) %>%  mutate(month = month(date), year = year(date)) %>% left_join(stations)  %>% group_by(month, name, year)  %>% summarise(NO_2 = mean(NO_2, na.rm = TRUE), n = n()) %>% filter(n > 500)

### Con loop
Archivos <- list.files("Clase6/csvs_per_year", full.names = TRUE)

Madrid <- map(Archivos, read_csv) %>% map(~filter(.x, station %in% c(28079036, 28079008,28079058, 28079060, 28079038))) %>%  map(~mutate(.x, month = month(date), year = year(date))) %>% map(~left_join(.x, stations)) %>% map(~group_by(.x, month, name, year))  %>% map(~summarise(.x, NO_2 = mean(NO_2, na.rm = TRUE), n = n())) %>% map(~filter(.x,n > 500)) %>%reduce(bind_rows)


ggplot(Madrid, aes(x = month, y = NO_2)) + geom_point(aes(color = year)) + geom_smooth() + theme_classic() + facet_wrap(~name)


ggplot(Madrid, aes(x = year, y = NO_2)) + geom_smooth(aes(fill = factor(month)),method = "lm") + theme_classic() + facet_wrap(~name)


for(i in 1:(length(Years)-1)){
  print(ggplot(Years[[i]], aes(x = month, y = NO_2)) + stat_smooth(method = "lm", formula = y ~ x + I(x^2), alpha = 0.5,aes(fill = name)) + geom_point() + ggtitle(unique(Years[[i]]$year)))
}

?animate
library(ggplot2)
library(gganimate)
Madrid2 <- filter(Madrid, year < 2018 & year > 2001)
ggplot(Madrid2,aes(x = month, y = NO_2)) + stat_smooth(method = "lm", formula = y ~ x + I(x^2), alpha = 0.5,aes(fill = name)) + geom_point() + 
  # Here comes the gganimate code
  transition_states(
    year, state_length = 2, transition_length = 1) +
  enter_fade() + 
  exit_shrink() +
  ease_aes('linear') + labs(title = 'Year: {closest_state}', x = 'Month', y = 'NO_2')


ggplot(Madrid2,aes(x = month, y = NO_2)) + stat_smooth(method = "lm", formula = y ~ x + I(x^2), alpha = 0.5,aes(fill = name)) + geom_point() + 
  # Here comes the gganimate code
  transition_time(year) +
  enter_fade() + 
  exit_shrink() +
  ease_aes('linear') + labs(title = 'Year: {round(frame_time,0)}', x = 'Month', y = 'NO_2')




ggplot(Madrid2,aes(x = month, y = NO_2)) + stat_smooth(method = "lm", formula = y ~ x + I(x^2), alpha = 0.5,aes(fill = name)) + geom_point() + 
  # Here comes the gganimate code
  transition_time(year) +
  enter_grow() + 
  exit_shrink() +
  ease_aes('linear') + labs(title = 'Year: {round(frame_time,0)}', x = 'Month', y = 'NO_2')

#### stackoverflow

library(tidyverse)
library(ggplot2)
library(gganimate)
Madrid3 <- filter(Madrid, year >= 2010 & year < 2018 & name == "Cuatro Caminos")
ggplot(Madrid3,aes(x = month, y = NO_2)) + stat_smooth(method = "lm", formula = y ~ x + I(x^2), alpha = 0.5,aes(fill = name)) + geom_point() + 
  # Here comes the gganimate code
  transition_states(
    year, state_length = 2, transition_length = 1) +
  enter_fade() + 
  exit_shrink() +
  ease_aes('linear') + labs(title = 'Year: {round(frame_states,0)}', x = 'Month', y = 'NO_2')




P2 <- ggplot(Madrid3,aes(x = month, y = NO_2)) + stat_smooth(method = "lm", formula = y ~ x + I(x^2), alpha = 0.5,aes(fill = name)) + geom_point() + 
  # Here comes the gganimate code
  transition_time(year) +
  enter_fade() + 
  exit_shrink() +
  ease_aes('linear') + labs(title = 'Year: {round(frame_time,0)}', x = 'Month', y = 'NO_2')


P2 <- animate(P2)

anim_save("TransitionTime.gif", P2)


