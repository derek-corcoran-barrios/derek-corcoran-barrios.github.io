library(tidyverse)
library(readxl)



Est <- read_excel("dimension-aire-factor-estado-excel.xlsx", sheet = "T001") %>% rename(Est_Meteoro = Codigo_Est_Meteoro) %>% dplyr::select(Est_Meteoro, Ciudad_localidad)

TempMedia <- read_excel("dimension-aire-factor-estado-excel.xlsx", sheet = "E10000003") %>% select(Mes, Año, ValorF, Est_Meteoro) %>% left_join(Est) %>% dplyr::select(-Est_Meteoro) %>% rename(Temperatura = ValorF)
HumMedia <- read_excel("dimension-aire-factor-estado-excel.xlsx", sheet = "E10000006") %>% select(Mes, Año, ValorF, Est_Meteoro) %>% left_join(Est) %>% dplyr::select(-Est_Meteoro) %>% rename(Humedad = ValorF)

TempHum <- full_join(TempMedia, HumMedia)

saveRDS(TempHum, "TempHum.rds")

ggplot(TempHum, aes(x = Mes, y = Temperatura)) + geom_point() + facet_wrap(~Ciudad_localidad)

