library(tidyverse)
library(broom)

mtcars

Compara_reg <- function(x, y, Comparacion = c("Lineal", "Cuadratico", "Logaritmico")){
  DF <- data.frame(x = x, y = y)
  
  Tabla1 <- list()
  Tabla2 <- list()
  Grafico <- list()
  if("Lineal" %in% Comparacion){
    Reg <- lm(y ~ x, data = DF)
    Tabla1[["Lineal"]] <- broom::glance(Reg) %>% mutate(Modelo = "Lineal")
    Tabla2[["Lineal"]] <- broom::tidy(Reg) %>% mutate(Modelo = "Lineal")
    Grafico[["Lineal"]] <- ggplot(data= DF, aes(x = x, y = y)) + stat_smooth(method = "lm", formula =  y ~ x) + theme_bw()
  }
  if("Cuadratico" %in% Comparacion){
    Reg <- lm(y ~ x + I(x^2), data = DF)
    Tabla1[["Cuadratico"]] <- broom::glance(Reg) %>% mutate(Modelo = "Cuadratico")
    Tabla2[["Cuadratico"]] <- broom::tidy(Reg) %>% mutate(Modelo = "Cuadratico")
    Grafico[["Cuadratico"]] <- ggplot(data= DF, aes(x = x, y = y)) + stat_smooth(method = "lm", formula =  y ~ x + I(x^2)) + theme_bw()
  }
  if("Logaritmico" %in% Comparacion){
    Reg <- lm(y ~ x + I(log(x)), data = DF)
    Tabla1[["Logaritmico"]] <- broom::glance(Reg) %>% mutate(Modelo = "Logaritmico")
    Tabla2[["Logaritmico"]] <- broom::tidy(Reg) %>% mutate(Modelo = "Logaritmico")
    Grafico[["Logaritmico"]] <- ggplot(data= DF, aes(x = x, y = y)) + stat_smooth(method = "lm", formula =  y ~ x + I(log(x))) + theme_bw()
  }
  
  Tabla1 <- Tabla1 %>% reduce(bind_rows) %>% arrange(AIC)
  Tabla2 <-Tabla2[[Tabla1$Modelo[[1]]]]
  Grafico <- Grafico[[Tabla1$Modelo[[1]]]]
  print(Grafico)
  message(paste("El mejor modelo fue el", Tabla1$Modelo[[1]]))
  return(list(Tabla_Modelo = Tabla1, Tabla_Parametros = Tabla2, Grafico = Grafico))
}

Res <- Compara_reg(x = mtcars$mpg, y = mtcars$hp, c("Lineal", "Cuadratico", "Logaritmico"))


