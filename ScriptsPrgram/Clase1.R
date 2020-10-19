# Cargar una base de datos con la funcion data

data("uspop")

#Crear un vector x

x = c(2,4,6,8,4,6,7)


## Para obtener el 5 elemento de uspop

uspop[5]

uspop[c(5,8)]

uspop[5:8]


x = c(2,4,6,8,10) 

y <- x[c(2,4)] 

### Data frames

data("iris")


Largo_Petalo <- iris$Petal.Length


Largo_setosa <- Largo_Petalo[1:50]

Largo_versicolor <- Largo_Petalo[51:100]

Largo_virginica <- Largo_Petalo[101:150]

## Ahora trabajemos tidy

library(tidyverse)

## Summarise para resumir

Resumen_Largo_Petalo <- summarise(iris, Largo_Petalo = mean(Petal.Length), Desviacion = sd(Petal.Length))
  
## Group_by y summarise para resumir por grupo


Resumen_Largo_Petalo <- group_by(iris, Species)
  
Resumen_Largo_Petalo <- summarise(Resumen_Largo_Petalo, Largo_Petalo = mean(Petal.Length), Desviacion = sd(Petal.Length))

write_csv(Resumen_Largo_Petalo, "Resumen.csv")

## Agrupar por mas de una base de datos

data("mtcars")


Eficiencia = group_by(mtcars, cyl, am)

Eficiencia <- summarise(Eficiencia, Eficiencia = mean(mpg), Numero = n())

## Mutate, crear variables nuevas

data(iris)



DF <- mutate(iris, RazonPetaloSepalo = Sepal.Length/Petal.Length)

DF <- group_by(DF, Species)

DF <- summarise(DF, RazonPetaloSepalo = mean(RazonPetaloSepalo), N = n())


# Para crear un pipeline en rstudio podemos apretar ctr +  shift + m

x <- c(1, 4, 6, 8)
y <- round(mean(sqrt(log(x))), 2)


y <- mean(sqrt(log(x)))

y <- x %>% log %>% sqrt %>% mean %>% round(3)


DF <- iris %>% 
  mutate(RazonPetaloSepalo = Sepal.Length/Petal.Length) %>% 
  group_by(Species) %>% 
  summarise(RazonPetaloSepalo = mean(RazonPetaloSepalo), N = n())


## Summarise all


Resumen <- iris %>% 
  group_by(Species) %>% 
  summarise_all(.funs = list(Media = mean, SD = sd))



## Filter


DF <- iris %>% filter(Petal.Length > 4, Petal.Width < 2) %>% 
  group_by(Species) %>% 
  summarise(Media = mean(Petal.Length), N = n())


DF <- iris %>% filter(Species == "virginica") %>% select(starts_with("Petal"))

DF <- iris %>% filter(Species == "virginica") %>% select(contains("Petal"))


DF2 <- iris[101:150,3:4]
