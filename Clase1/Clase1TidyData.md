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
date: "04/08, 2018"
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


Pipeline (%>%)
=================
class: small-code
incremental: true

- Ahorra líneas, se parte con un data.frame
- Se agregan funciones de dplyr hasta llegar al resultado deseado


```r
library(tidyverse)
MEAN <- iris %>% group_by(Species) %>% summarize(MEAN.PETAL = mean(Petal.Length))
```



|Species    | MEAN.PETAL|
|:----------|----------:|
|setosa     |      1.462|
|versicolor |      4.260|
|virginica  |      5.552|

Pipeline (%>%) otro ejemplo
==========================


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

* Selecciona columnas dentro de un data.frame


```r
data(nasa)
Nasa2 <- as.data.frame(nasa)
Temp <- Nasa2 %>% filter(year != 1995) %>% group_by(year) %>% select(contains("temp")) %>% summarize_all(mean)
```
***

| year| surftemp| temperature|
|----:|--------:|-----------:|
| 1996| 295.8562|    297.1005|
| 1997| 296.7291|    297.9566|
| 1998| 297.1221|    298.7028|
| 1999| 295.6850|    298.1364|
| 2000| 295.7263|    298.3358|

mutate
=======================
class: small-code

* Crea variables nuevas


```r
DF <- iris %>% mutate(Petal.Sepal.Ratio = Petal.Length/Sepal.Length) %>% select(Petal.Length, Sepal.Length, Petal.Sepal.Ratio, Species)
```


| Petal.Length| Sepal.Length| Petal.Sepal.Ratio|Species    |
|------------:|------------:|-----------------:|:----------|
|          1.4|          5.1|         0.2745098|setosa     |
|          1.4|          4.9|         0.2857143|setosa     |
|          1.3|          4.7|         0.2765957|setosa     |
|          1.5|          4.6|         0.3260870|setosa     |
|          1.4|          5.0|         0.2800000|setosa     |
|          1.7|          5.4|         0.3148148|setosa     |
|          1.4|          4.6|         0.3043478|setosa     |
|          1.5|          5.0|         0.3000000|setosa     |
|          1.4|          4.4|         0.3181818|setosa     |
|          1.5|          4.9|         0.3061224|setosa     |
|          1.5|          5.4|         0.2777778|setosa     |
|          1.6|          4.8|         0.3333333|setosa     |
|          1.4|          4.8|         0.2916667|setosa     |
|          1.1|          4.3|         0.2558140|setosa     |
|          1.2|          5.8|         0.2068966|setosa     |
|          1.5|          5.7|         0.2631579|setosa     |
|          1.3|          5.4|         0.2407407|setosa     |
|          1.4|          5.1|         0.2745098|setosa     |
|          1.7|          5.7|         0.2982456|setosa     |
|          1.5|          5.1|         0.2941176|setosa     |
|          1.7|          5.4|         0.3148148|setosa     |
|          1.5|          5.1|         0.2941176|setosa     |
|          1.0|          4.6|         0.2173913|setosa     |
|          1.7|          5.1|         0.3333333|setosa     |
|          1.9|          4.8|         0.3958333|setosa     |
|          1.6|          5.0|         0.3200000|setosa     |
|          1.6|          5.0|         0.3200000|setosa     |
|          1.5|          5.2|         0.2884615|setosa     |
|          1.4|          5.2|         0.2692308|setosa     |
|          1.6|          4.7|         0.3404255|setosa     |
|          1.6|          4.8|         0.3333333|setosa     |
|          1.5|          5.4|         0.2777778|setosa     |
|          1.5|          5.2|         0.2884615|setosa     |
|          1.4|          5.5|         0.2545455|setosa     |
|          1.5|          4.9|         0.3061224|setosa     |
|          1.2|          5.0|         0.2400000|setosa     |
|          1.3|          5.5|         0.2363636|setosa     |
|          1.4|          4.9|         0.2857143|setosa     |
|          1.3|          4.4|         0.2954545|setosa     |
|          1.5|          5.1|         0.2941176|setosa     |
|          1.3|          5.0|         0.2600000|setosa     |
|          1.3|          4.5|         0.2888889|setosa     |
|          1.3|          4.4|         0.2954545|setosa     |
|          1.6|          5.0|         0.3200000|setosa     |
|          1.9|          5.1|         0.3725490|setosa     |
|          1.4|          4.8|         0.2916667|setosa     |
|          1.6|          5.1|         0.3137255|setosa     |
|          1.4|          4.6|         0.3043478|setosa     |
|          1.5|          5.3|         0.2830189|setosa     |
|          1.4|          5.0|         0.2800000|setosa     |
|          4.7|          7.0|         0.6714286|versicolor |
|          4.5|          6.4|         0.7031250|versicolor |
|          4.9|          6.9|         0.7101449|versicolor |
|          4.0|          5.5|         0.7272727|versicolor |
|          4.6|          6.5|         0.7076923|versicolor |
|          4.5|          5.7|         0.7894737|versicolor |
|          4.7|          6.3|         0.7460317|versicolor |
|          3.3|          4.9|         0.6734694|versicolor |
|          4.6|          6.6|         0.6969697|versicolor |
|          3.9|          5.2|         0.7500000|versicolor |
|          3.5|          5.0|         0.7000000|versicolor |
|          4.2|          5.9|         0.7118644|versicolor |
|          4.0|          6.0|         0.6666667|versicolor |
|          4.7|          6.1|         0.7704918|versicolor |
|          3.6|          5.6|         0.6428571|versicolor |
|          4.4|          6.7|         0.6567164|versicolor |
|          4.5|          5.6|         0.8035714|versicolor |
|          4.1|          5.8|         0.7068966|versicolor |
|          4.5|          6.2|         0.7258065|versicolor |
|          3.9|          5.6|         0.6964286|versicolor |
|          4.8|          5.9|         0.8135593|versicolor |
|          4.0|          6.1|         0.6557377|versicolor |
|          4.9|          6.3|         0.7777778|versicolor |
|          4.7|          6.1|         0.7704918|versicolor |
|          4.3|          6.4|         0.6718750|versicolor |
|          4.4|          6.6|         0.6666667|versicolor |
|          4.8|          6.8|         0.7058824|versicolor |
|          5.0|          6.7|         0.7462687|versicolor |
|          4.5|          6.0|         0.7500000|versicolor |
|          3.5|          5.7|         0.6140351|versicolor |
|          3.8|          5.5|         0.6909091|versicolor |
|          3.7|          5.5|         0.6727273|versicolor |
|          3.9|          5.8|         0.6724138|versicolor |
|          5.1|          6.0|         0.8500000|versicolor |
|          4.5|          5.4|         0.8333333|versicolor |
|          4.5|          6.0|         0.7500000|versicolor |
|          4.7|          6.7|         0.7014925|versicolor |
|          4.4|          6.3|         0.6984127|versicolor |
|          4.1|          5.6|         0.7321429|versicolor |
|          4.0|          5.5|         0.7272727|versicolor |
|          4.4|          5.5|         0.8000000|versicolor |
|          4.6|          6.1|         0.7540984|versicolor |
|          4.0|          5.8|         0.6896552|versicolor |
|          3.3|          5.0|         0.6600000|versicolor |
|          4.2|          5.6|         0.7500000|versicolor |
|          4.2|          5.7|         0.7368421|versicolor |
|          4.2|          5.7|         0.7368421|versicolor |
|          4.3|          6.2|         0.6935484|versicolor |
|          3.0|          5.1|         0.5882353|versicolor |
|          4.1|          5.7|         0.7192982|versicolor |
|          6.0|          6.3|         0.9523810|virginica  |
|          5.1|          5.8|         0.8793103|virginica  |
|          5.9|          7.1|         0.8309859|virginica  |
|          5.6|          6.3|         0.8888889|virginica  |
|          5.8|          6.5|         0.8923077|virginica  |
|          6.6|          7.6|         0.8684211|virginica  |
|          4.5|          4.9|         0.9183673|virginica  |
|          6.3|          7.3|         0.8630137|virginica  |
|          5.8|          6.7|         0.8656716|virginica  |
|          6.1|          7.2|         0.8472222|virginica  |
|          5.1|          6.5|         0.7846154|virginica  |
|          5.3|          6.4|         0.8281250|virginica  |
|          5.5|          6.8|         0.8088235|virginica  |
|          5.0|          5.7|         0.8771930|virginica  |
|          5.1|          5.8|         0.8793103|virginica  |
|          5.3|          6.4|         0.8281250|virginica  |
|          5.5|          6.5|         0.8461538|virginica  |
|          6.7|          7.7|         0.8701299|virginica  |
|          6.9|          7.7|         0.8961039|virginica  |
|          5.0|          6.0|         0.8333333|virginica  |
|          5.7|          6.9|         0.8260870|virginica  |
|          4.9|          5.6|         0.8750000|virginica  |
|          6.7|          7.7|         0.8701299|virginica  |
|          4.9|          6.3|         0.7777778|virginica  |
|          5.7|          6.7|         0.8507463|virginica  |
|          6.0|          7.2|         0.8333333|virginica  |
|          4.8|          6.2|         0.7741935|virginica  |
|          4.9|          6.1|         0.8032787|virginica  |
|          5.6|          6.4|         0.8750000|virginica  |
|          5.8|          7.2|         0.8055556|virginica  |
|          6.1|          7.4|         0.8243243|virginica  |
|          6.4|          7.9|         0.8101266|virginica  |
|          5.6|          6.4|         0.8750000|virginica  |
|          5.1|          6.3|         0.8095238|virginica  |
|          5.6|          6.1|         0.9180328|virginica  |
|          6.1|          7.7|         0.7922078|virginica  |
|          5.6|          6.3|         0.8888889|virginica  |
|          5.5|          6.4|         0.8593750|virginica  |
|          4.8|          6.0|         0.8000000|virginica  |
|          5.4|          6.9|         0.7826087|virginica  |
|          5.6|          6.7|         0.8358209|virginica  |
|          5.1|          6.9|         0.7391304|virginica  |
|          5.1|          5.8|         0.8793103|virginica  |
|          5.9|          6.8|         0.8676471|virginica  |
|          5.7|          6.7|         0.8507463|virginica  |
|          5.2|          6.7|         0.7761194|virginica  |
|          5.0|          6.3|         0.7936508|virginica  |
|          5.2|          6.5|         0.8000000|virginica  |
|          5.4|          6.2|         0.8709677|virginica  |
|          5.1|          5.9|         0.8644068|virginica  |

Ejercicios
========================================================
incremental: true

* Usando la base de datos *storm* del paquete *dplyr*, calcula la velocidad promedio y diámetro promedio (hu_diameter) de las tormentas declaradas huracanes por año
    + solución:
    + storms %>% filter(status == "hurricane") %>% select(year, wind, hu_diameter) %>% group_by(year) %>% summarize_all(mean)
    + storms %>% filter(status == "hurricane" & !is.na(hu_diameter)) %>% select(year, wind, hu_diameter) %>% group_by(year) %>% summarize_all(mean)
    + storms %>% filter(status == "hurricane") %>% select(year, wind, hu_diameter) %>% group_by(year) %>% summarize_all(funs(mean), na.rm = TRUE)

Ejercicios 2
==================================
incremental: true

* La base de datos mpg tiene datos de eficiencia vehicular en millas por galón en ciudad (*cty*) en varios vehículos, obten los datos de vehiculos del año 2004 en adelante, que sean compactos, y transforma la eficiencia  Km/litro (1 km = 1.609 millas; 1 galón = 3.78541 litros)
    + Solution <- mpg %>% filter(year > 2004 & class == "compact") %>% mutate(kpl = (cty*1.609)/3.78541)

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
