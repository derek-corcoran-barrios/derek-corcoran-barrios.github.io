<style>
.reveal h1, .reveal h2, .reveal h3 {
  word-wrap: normal;
  -moz-hyphens: none;
}
</style>

<style>
.small-code pre code {
  font-size: 1em;
}
</style>

Clase 1 Tidy Data y manipulación de datos
========================================================
author: Derek Corcoran
date: "05/08, 2018"
autosize: true
transition: rotate


Curso Análisis y manipulación de datos en R
========================================================

Primeros pasos

- ¿Quien no ha usado nunca R? [Swirl](http://swirlstats.com/students.html)
- Evaluación sencilla (Completar tareas + 1 evaluación)
- Mucho trabajo personal guiado
- Pagina donde esta [todo el curso](https://github.com/derek-corcoran-barrios/CursoR)

Estructura de datos
========================================================
incremental: true

- Vector: Un conjunto lineal de datos (secuencia génica, serie de tiempo)
- Matrix: Una tabla con solo números
- Data Frame: Una tabla donde cada columna tiene un tipo de datos (estándar dorado)
- List: Aqui podemos meter lo que queramos

***

![data](Data.png)

Vector
========================================================
left: 60%
incremental: true

* Secuencia lineal de datos
* Pueden ser de muchos tipos (numéricos, de carácteres, lógicos, etc.)
* Ejemplo data(uspop)
* para crear uno c(1,4,6,7,8)
* para subsetear un vector se pone el índice entre []
* uspop[4], uspop[2:10], uspop[c(3,5,8)]

***

![Vector](Vector.jpg)


Data Frame
========================================================
incremental: true
* Una tabla, cada columna un tipo de datos (Numérico, lógico, etc)
* Cada columna un vector
* Ejemplo data(iris)
* Para subsetear data.frame[filas,columnas]
* Ejemplos iris[,3], iris[,"Petal.Length"], iris[2:5,c(1,5)], iris$Petal.Length



***

![DataFrame](DataFrame.jpg)

Tidy Data 
========================================================
incremental: true
![Tidy](tidy.png)

* Cada columna una variable
* Cada fila una observación

untidy data
===========
<img src="UntidyONU.png" title="plot of chunk unnamed-chunk-1" alt="plot of chunk unnamed-chunk-1" width="960px" height="700px" />

untidy data
===========

<img src="untidy.jpg" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" width="960px" height="450px" />

untidy data
===========
class: small-code

* Tablas de contingencia
* Ejemplo data(HairEyeColor)


```r
data("HairEyeColor")
HairEyeColor[,,1]
```

```
       Eye
Hair    Brown Blue Hazel Green
  Black    32   11    10     3
  Brown    53   50    25    15
  Red      10   10     7     7
  Blond     3   30     5     8
```
***
### Forma tidy


|Hair  |Eye   |Sex  |
|:-----|:-----|:----|
|Black |Brown |Male |
|Black |Brown |Male |
|Black |Brown |Male |
|Black |Brown |Male |
|Black |Brown |Male |
|Black |Brown |Male |

dplyr
========================================================
incremental: true
 
* Paquete con pocas funciones [muy poderosas](https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf) para ordenar datos 
* Parte del [tidyverse](https://www.tidyverse.org/)

- *group_by* (agrupa datos)
- *summarize* (resume datos agrupados)
- *filter* (Encuentra filas con ciertas condiciones)
- *select* junto a *starts_with*, *ends_with* o *contains*
- *mutate* (Genera variables nuevas)
- *%>%* pipeline

summarize y group_by
=================
class: small-code
incremental: true

- *group_by* reune observaciones según una variable
- *summarize* resume una variable


```r
library(tidyverse)
Summary.Petal <- summarize(iris, Mean.Petal.Length = mean(Petal.Length), SD.Petal.Length = sd(Petal.Length))
```



| Mean.Petal.Length| SD.Petal.Length|
|-----------------:|---------------:|
|             3.758|        1.765298|

summarize y group_by (continuado)
=================
class: small-code
incremental: true


```r
library(tidyverse)
Summary.Petal <- group_by(iris, Species)
Summary.Petal <- summarize(Summary.Petal, Mean.Petal.Length = mean(Petal.Length), SD.Petal.Length = sd(Petal.Length))
```



|Species    | Mean.Petal.Length| SD.Petal.Length|
|:----------|-----------------:|---------------:|
|setosa     |             1.462|       0.1736640|
|versicolor |             4.260|       0.4699110|
|virginica  |             5.552|       0.5518947|

summarize y group_by (continuado)
=================
class: small-code
incremental: true

* Pueden agrupar por más de una variable a la vez


```r
data("mtcars")
Mtcars2 <- group_by(mtcars, am, cyl)
Consumo <- summarize(Mtcars2, Consumo_promedio = mean(mpg), desv = sd(mpg))
```



| am| cyl| Consumo_promedio|      desv|
|--:|---:|----------------:|---------:|
|  0|   4|         22.90000| 1.4525839|
|  0|   6|         19.12500| 1.6317169|
|  0|   8|         15.05000| 2.7743959|
|  1|   4|         28.07500| 4.4838599|
|  1|   6|         20.56667| 0.7505553|
|  1|   8|         15.40000| 0.5656854|



mutate
=======================
class: small-code

* Crea variables nuevas


```r
DF <- mutate(iris, Petal.Sepal.Ratio = Petal.Length/Sepal.Length)
```


| Sepal.Length| Sepal.Width| Petal.Length| Petal.Width|Species    | Petal.Sepal.Ratio|
|------------:|-----------:|------------:|-----------:|:----------|-----------------:|
|          5.8|         4.0|          1.2|         0.2|setosa     |              0.21|
|          4.7|         3.2|          1.6|         0.2|setosa     |              0.34|
|          5.1|         3.8|          1.9|         0.4|setosa     |              0.37|
|          5.2|         2.7|          3.9|         1.4|versicolor |              0.75|
|          6.4|         2.9|          4.3|         1.3|versicolor |              0.67|
|          5.5|         2.5|          4.0|         1.3|versicolor |              0.73|
|          6.5|         3.0|          5.8|         2.2|virginica  |              0.89|
|          6.0|         2.2|          5.0|         1.5|virginica  |              0.83|
|          6.1|         2.6|          5.6|         1.4|virginica  |              0.92|
|          5.9|         3.0|          5.1|         1.8|virginica  |              0.86|

Pipeline (%>%)
=================
class: small-code
incremental: true

- Para realizar varias operaciones de forma secuencial 
- sin recurrir a parentesis anidados 
- sobrescribir multiples bases de datos


```r
x <- c(1,4,6,8)
y <- round(mean(sqrt(log(x))),2)
```

- Que hice ahí?


```r
x <- c(1,4,6,8)
y <- x %>% log() %>% sqrt() %>% mean() %>% round(2)
```


```
[1] 0.99
```

Pipeline (%>%)
=================
class: small-code
incremental: true

* Muchos objetos intermedios


```r
DF <- mutate(iris, Petal.Sepal.Ratio = Petal.Length/Sepal.Length)
BySpecies <- group_by(DF, Species)
Summary.Byspecies <- summarize(BySpecies, MEAN = mean(Petal.Sepal.Ratio), SD = sd(Petal.Sepal.Ratio))
```



|Species    |      MEAN|        SD|
|:----------|---------:|---------:|
|setosa     | 0.2927557| 0.0347958|
|versicolor | 0.7177285| 0.0536255|
|virginica  | 0.8437495| 0.0438064|

Pipeline (%>%)
=================
class: small-code
incremental: true

* Con pipe


```r
Summary.Byspecies <- summarize(group_by(mutate(iris, Petal.Sepal.Ratio = Petal.Length/Sepal.Length), Species), MEAN = mean(Petal.Sepal.Ratio), SD = sd(Petal.Sepal.Ratio))
```



|Species    |      MEAN|        SD|
|:----------|---------:|---------:|
|setosa     | 0.2927557| 0.0347958|
|versicolor | 0.7177285| 0.0536255|
|virginica  | 0.8437495| 0.0438064|



Pipeline (%>%) otro ejemplo
==========================
class: small-code


```r
library(tidyverse)
MEAN <- iris %>% group_by(Species) %>% summarize_all(mean)
```


|Species    | Sepal.Length| Sepal.Width| Petal.Length| Petal.Width|
|:----------|------------:|-----------:|------------:|-----------:|
|setosa     |        5.006|       3.428|        1.462|       0.246|
|versicolor |        5.936|       2.770|        4.260|       1.326|
|virginica  |        6.588|       2.974|        5.552|       2.026|

Filter
=======
incremental:true
- Selecciona según una o más variables


|simbolo |significado     |simbolo_cont |significado_cont |
|:-------|:---------------|:------------|:----------------|
|>       |Mayor que       |!=           |distinto a       |
|<       |Menor que       |%in%         |dentro del grupo |
|==      |Igual a         |is.na        |es NA            |
|>=      |mayor o igual a |!is.na       |no es NA         |
|<=      |menor o igual a |&#124; &     |o, y             |

Ejemplos de filter agregando a lo anterior
===============================
class: small-code


```r
data("iris")
DF <- iris %>% filter(Species != "versicolor") %>% group_by(Species) %>% summarise_all(mean)
```


|Species   | Sepal.Length| Sepal.Width| Petal.Length| Petal.Width|
|:---------|------------:|-----------:|------------:|-----------:|
|setosa    |        5.006|       3.428|        1.462|       0.246|
|virginica |        6.588|       2.974|        5.552|       2.026|

Ejemplos de filter
===============================
class: small-code


```r
DF <- iris %>% filter(Petal.Length >= 4 & Sepal.Length >= 5) %>% group_by(Species) %>% summarise(N = n())
```


|Species    |  N|
|:----------|--:|
|versicolor | 39|
|virginica  | 49|


Más de una función
===============================
class: small-code


```r
data("iris")
DF <- iris %>% filter(Species != "versicolor") %>% group_by(Species) %>% summarise_all(funs(mean, sd))
```


|Species   | Sepal.Length_mean| Sepal.Width_mean| Petal.Length_mean| Petal.Width_mean| Sepal.Length_sd| Sepal.Width_sd| Petal.Length_sd| Petal.Width_sd|
|:---------|-----------------:|----------------:|-----------------:|----------------:|---------------:|--------------:|---------------:|--------------:|
|setosa    |             5.006|            3.428|             1.462|            0.246|       0.3524897|      0.3790644|       0.1736640|      0.1053856|
|virginica |             6.588|            2.974|             5.552|            2.026|       0.6358796|      0.3224966|       0.5518947|      0.2746501|

Select
=======================
class: small-code
incremental: true

* Selecciona columnas dentro de un data.frame, se pueden restar


```r
iris %>% group_by(Species) %>% select(Petal.Length, Petal.Width) %>% summarize_all(mean)
```


```r
iris %>% group_by(Species) %>% select(-Sepal.Length, -Sepal.Width) %>% summarize_all(mean)
```


```r
iris %>% group_by(Species) %>% select(contains("Petal")) %>% summarize_all(mean)
```


```r
iris %>% group_by(Species) %>% select(-contains("Sepal")) %>% summarize_all(mean)
```



***

|Species    | Petal.Length| Petal.Width|
|:----------|------------:|-----------:|
|setosa     |        1.462|       0.246|
|versicolor |        4.260|       1.326|
|virginica  |        5.552|       2.026|


Ejercicios
========================================================
incremental: true
class: small-code

* Usando la base de datos *storm* del paquete *dplyr*, calcula la velocidad promedio y diámetro promedio (hu_diameter) de las tormentas declaradas huracanes por año
    + soluciónes:

```r
storms %>% filter(status == "hurricane") %>% select(year, wind, hu_diameter) %>% group_by(year) %>% summarize_all(mean)
```


```r
storms %>% filter(status == "hurricane" & !is.na(hu_diameter)) %>% select(year, wind, hu_diameter) %>% group_by(year) %>% summarize_all(mean)
```


```r
storms %>% filter(status == "hurricane") %>% select(year, wind, hu_diameter) %>% group_by(year) %>% summarize_all(funs(mean), na.rm = TRUE)
```

Ejercicios 2
==================================
incremental: true
class: small-code

* La base de datos `mpg` del paquete ggplot2 tiene datos de eficiencia vehicular en millas por galón en ciudad (*cty*) en varios vehículos, obten los datos de vehiculos del año 2004 en adelante, que sean compactos, y transforma la eficiencia  Km/litro (1 km = 1.609 millas; 1 galón = 3.78541 litros)


```r
Solution <- mpg %>% filter(year > 2004 & class == "compact") %>% mutate(kpl = (cty*1.609)/3.78541)
```

Bases de datos con que trabajar
========================================================

- [Awesome public Datasets](https://github.com/caesar0301/awesome-public-datasets)
- [Ropensci](https://ropensci.org/packages/#data_access) en base a paquetes de R
- [cooldatasets](https://www.cooldatasets.com/)
- [Datos de FiveThirtyEight](https://github.com/fivethirtyeight/data/tree/master/)



Consejo reproducible 1
========================================================
class: small-code

Usar el paquete pacman (Package manager)

- En R usar los mismos paquetes es clave para reproducibilidad
- *p_load* cargar el paquete, si no esta instalarlo y luego cargarlo
- El código de abajo busca el paquete pacman, si no esta lo instala
- Luego usa *p_load* sobre los otros paquetes

***


```r
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, lubridate)
```
