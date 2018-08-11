download.file("http://www.ine.cl/docs/default-source/medioambiente-(micrositio)/variables-b%C3%A1sicas-ambientales-(vba)/aire/dimensi%C3%B3n-aire-factor-estado.xlsx?sfvrsn=4", destfile = "test.xlsx")

#para leer los archivos
library(readxl)
#Para manipular los datos
library(dplyr)
#Para transformar los textos
library(stringr)
#para generar las fechas
library(lubridate)
####Leer la pestaña estaciones Meteorologicas
EM <- read_excel("test.xlsx", sheet = "T001")
#Cambiar el nombre de la columna 1 para que sea igual que las columnas de la temperatura y humedad
colnames(EM)[1] <- "Est_Meteoro"

########################################################################
####Leer la pestaña de la temperatura media
TempMedia <- read_excel("~/Downloads/estado-aire80422dea683e61618024ff030098b759.xlsx", sheet = "E10000003")

#Eliminar de TempMedia las columnas codigo variable y Unidad de medida, y 
#cambiar el nombre de la columna valorF a TempMedia

TempMedia <- TempMedia %>% select(-Codigo_variable, -Unidad_medida)
colnames(TempMedia)[4] <- "TempMedia"

#Eliminar fechas con valor de mes 13

TempMedia <- TempMedia[!str_detect(TempMedia$Fecha, "_13"),]

#Remplazar dias 00, por 01

TempMedia$Fecha <- str_replace(TempMedia$Fecha, "_00", "_01")

##Transformar en formato Fecha

TempMedia$Fecha <- ymd(TempMedia$Fecha)

#Generar las columas para mes y año

TempMedia$Year <- year(TempMedia$Fecha)

TempMedia$mes <- month(TempMedia$Fecha)

TempMedia <- left_join(TempMedia, EM) %>% select(Fecha, Year, mes, TempMedia, Ciudad_localidad)


##############################################################################################3
####Leer la pestaña Humedad Media
HumMedia <- read_excel("~/Downloads/estado-aire80422dea683e61618024ff030098b759.xlsx", sheet = "E10000006")


#Eliminar de HumMedia las columnas codigo variable y Unidad de medida, y 
#cambiar el nombre de la columna valorF a HumMedia

HumMedia <- HumMedia %>% select(-Codigo_variable, -Unidad_medida)
colnames(HumMedia)[4] <- "HumMedia"

#Eliminar fechas con valor de mes 13

HumMedia <- HumMedia[!str_detect(HumMedia$Fecha, "_13"),]

#Remplazar dias 00, por 01

HumMedia$Fecha <- str_replace(HumMedia$Fecha, "_00", "_01")

##Transformar en formato Fecha

HumMedia$Fecha <- ymd(HumMedia$Fecha)

#Generar las columas para mes y año

HumMedia$Year <- year(HumMedia$Fecha)

HumMedia$mes <- month(HumMedia$Fecha)

HumMedia <- left_join(HumMedia, EM) %>% select(Fecha, Year, mes, HumMedia, Ciudad_localidad)

TempHum <- full_join(TempMedia, HumMedia)

saveRDS(TempHum, "TempHum.rds")

TempHum <- readRDS("TempHum.rds")
