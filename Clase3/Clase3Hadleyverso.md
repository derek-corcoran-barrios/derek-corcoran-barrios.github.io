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

Clase 3 El Tidyverso
========================================================
author: Derek Corcoran
date: "11/08, 2018"
autosize: true
transition: rotate


Tidiverso
========================================================
class: small-code





Hadleyverso: Conjunto de paquetes creado por Hadley Wickham, generados para hacer el trabajo con Tidy Data mucho más fácil

![plot of chunk unnamed-chunk-2](http://hadley.nz/hadley-wickham.jpg)

***

[Tidyverso](https://www.tidyverse.org): Desde que David Robinson y algunos otros empezaron a aportar


```r
install.packages("tidyverse")
library(tidyverse)
```

![plot of chunk unnamed-chunk-4](http://varianceexplained.org/images/david_robinson_picture2.jpg)

Paquetes del Tidyverso
========================================================
incremental: true

En el corazón del Tidyverso

* readr (ya la estamos usando)
* dplyr (Clase anterior)
* tidyr (Hoy)
* forcats (Para variables categóricas)
* stringr (Para carácteres, Palabras)
* ggplot2 (Próxima clase)
* purrr (En clase sobre loops)

 ***
 
Adyacente al Tidyverso

* lubridate para fechas y fechas/horas (Hoy en algunos casos)
* hms para horas
* broom tablas para modelos tidy
* readxl para leer archivos excel

Tidyr
====================

Dos funciones

* *gather* hace que tablas anchas se vuelvan largas
* *spread* hace que tablas largas se vuelvan anchan

***

![plot of chunk unnamed-chunk-5](https://exceleratorbi.com.au/wp-content/uploads/2016/09/image.png)

Gather
=============
class: small-code


```r
data(iris)
mini_iris <- iris[c(1, 51, 101), ]
kable(mini_iris)
```



|    | Sepal.Length| Sepal.Width| Petal.Length| Petal.Width|Species    |
|:---|------------:|-----------:|------------:|-----------:|:----------|
|1   |          5.1|         3.5|          1.4|         0.2|setosa     |
|51  |          7.0|         3.2|          4.7|         1.4|versicolor |
|101 |          6.3|         3.3|          6.0|         2.5|virginica  |

Gather (cont)
=============
class: small-code


```r
MI <- mini_iris %>% gather(key = flower_att, value = measurement, -Species)
kable(MI)
```



|Species    |flower_att   | measurement|
|:----------|:------------|-----------:|
|setosa     |Sepal.Length |         5.1|
|versicolor |Sepal.Length |         7.0|
|virginica  |Sepal.Length |         6.3|
|setosa     |Sepal.Width  |         3.5|
|versicolor |Sepal.Width  |         3.2|
|virginica  |Sepal.Width  |         3.3|
|setosa     |Petal.Length |         1.4|
|versicolor |Petal.Length |         4.7|
|virginica  |Petal.Length |         6.0|
|setosa     |Petal.Width  |         0.2|
|versicolor |Petal.Width  |         1.4|
|virginica  |Petal.Width  |         2.5|


spread
============

```r
M <- spread(MI, flower_att, measurement)
kable(M)
```



|Species    | Petal.Length| Petal.Width| Sepal.Length| Sepal.Width|
|:----------|------------:|-----------:|------------:|-----------:|
|setosa     |          1.4|         0.2|          5.1|         3.5|
|versicolor |          4.7|         1.4|          7.0|         3.2|
|virginica  |          6.0|         2.5|          6.3|         3.3|

Ejercicios
==============
incremental: true
class: small-code
* ¿Como paso de esto?

```r
counts_df <- data.frame(
  day = c("Monday", "Tuesday", "Wednesday"),
  wolf = c(2, 1, 3),
  hare = c(20, 25, 30),
  fox = c(4, 4, 4)
)
kable(counts_df)
```



|day       | wolf| hare| fox|
|:---------|----:|----:|---:|
|Monday    |    2|   20|   4|
|Tuesday   |    1|   25|   4|
|Wednesday |    3|   30|   4|

* a tidy data?

Solución
==============
class: small-code


```r
DF <- counts_df %>% gather(key = Species, value = Count, -day)
kable(DF)
```



|day       |Species | Count|
|:---------|:-------|-----:|
|Monday    |wolf    |     2|
|Tuesday   |wolf    |     1|
|Wednesday |wolf    |     3|
|Monday    |hare    |    20|
|Tuesday   |hare    |    25|
|Wednesday |hare    |    30|
|Monday    |fox     |     4|
|Tuesday   |fox     |     4|
|Wednesday |fox     |     4|


Ejercicio 2
=================
class: small-code
a. Quedarse con solo las observaciones que tienen coordenadas geograficas

b. Cuantas observaciones son de observacion humana y cuantas de especimen de museo? 

```r
library(dismo)
library(dplyr)
Huemul <- gbif('Hippocamelus', 'bisulcus', down=TRUE)
colnames(Huemul)
```

```
  [1] "accessRights"                                                        
  [2] "adm1"                                                                
  [3] "adm2"                                                                
  [4] "basisOfRecord"                                                       
  [5] "catalogNumber"                                                       
  [6] "class"                                                               
  [7] "classKey"                                                            
  [8] "cloc"                                                                
  [9] "collectionCode"                                                      
 [10] "collectionID"                                                        
 [11] "continent"                                                           
 [12] "coordinatePrecision"                                                 
 [13] "coordinateUncertaintyInMeters"                                       
 [14] "country"                                                             
 [15] "crawlId"                                                             
 [16] "datasetID"                                                           
 [17] "datasetKey"                                                          
 [18] "datasetName"                                                         
 [19] "dateIdentified"                                                      
 [20] "day"                                                                 
 [21] "depth"                                                               
 [22] "depthAccuracy"                                                       
 [23] "disposition"                                                         
 [24] "dynamicProperties"                                                   
 [25] "elevation"                                                           
 [26] "elevationAccuracy"                                                   
 [27] "endDayOfYear"                                                        
 [28] "establishmentMeans"                                                  
 [29] "eventDate"                                                           
 [30] "eventRemarks"                                                        
 [31] "eventTime"                                                           
 [32] "family"                                                              
 [33] "familyKey"                                                           
 [34] "fieldNumber"                                                         
 [35] "fullCountry"                                                         
 [36] "gbifID"                                                              
 [37] "genericName"                                                         
 [38] "genus"                                                               
 [39] "genusKey"                                                            
 [40] "geodeticDatum"                                                       
 [41] "georeferencedBy"                                                     
 [42] "georeferencedDate"                                                   
 [43] "georeferenceProtocol"                                                
 [44] "georeferenceSources"                                                 
 [45] "georeferenceVerificationStatus"                                      
 [46] "higherClassification"                                                
 [47] "higherGeography"                                                     
 [48] "http://unknown.org/http_//rs.gbif.org/terms/1.0/Multimedia"          
 [49] "http://unknown.org/http_//rs.tdwg.org/dwc/terms/Identification"      
 [50] "http://unknown.org/http_//rs.tdwg.org/dwc/terms/ResourceRelationship"
 [51] "http://unknown.org/occurrenceDetails"                                
 [52] "identificationID"                                                    
 [53] "identificationQualifier"                                             
 [54] "identificationRemarks"                                               
 [55] "identificationVerificationStatus"                                    
 [56] "identifiedBy"                                                        
 [57] "identifier"                                                          
 [58] "individualCount"                                                     
 [59] "informationWithheld"                                                 
 [60] "installationKey"                                                     
 [61] "institutionCode"                                                     
 [62] "institutionID"                                                       
 [63] "ISO2"                                                                
 [64] "key"                                                                 
 [65] "kingdom"                                                             
 [66] "kingdomKey"                                                          
 [67] "language"                                                            
 [68] "lastCrawled"                                                         
 [69] "lastInterpreted"                                                     
 [70] "lastParsed"                                                          
 [71] "lat"                                                                 
 [72] "license"                                                             
 [73] "locality"                                                            
 [74] "locationAccordingTo"                                                 
 [75] "locationRemarks"                                                     
 [76] "lon"                                                                 
 [77] "modified"                                                            
 [78] "month"                                                               
 [79] "nomenclaturalCode"                                                   
 [80] "occurrenceID"                                                        
 [81] "occurrenceRemarks"                                                   
 [82] "occurrenceStatus"                                                    
 [83] "order"                                                               
 [84] "orderKey"                                                            
 [85] "organismID"                                                          
 [86] "organismRemarks"                                                     
 [87] "otherCatalogNumbers"                                                 
 [88] "ownerInstitutionCode"                                                
 [89] "phylum"                                                              
 [90] "phylumKey"                                                           
 [91] "preparations"                                                        
 [92] "previousIdentifications"                                             
 [93] "protocol"                                                            
 [94] "publishingCountry"                                                   
 [95] "publishingOrgKey"                                                    
 [96] "recordedBy"                                                          
 [97] "recordNumber"                                                        
 [98] "references"                                                          
 [99] "rights"                                                              
[100] "rightsHolder"                                                        
[101] "scientificName"                                                      
[102] "sex"                                                                 
[103] "species"                                                             
[104] "speciesKey"                                                          
[105] "specificEpithet"                                                     
[106] "startDayOfYear"                                                      
[107] "taxonID"                                                             
[108] "taxonKey"                                                            
[109] "taxonRank"                                                           
[110] "type"                                                                
[111] "verbatimCoordinateSystem"                                            
[112] "verbatimEventDate"                                                   
[113] "verbatimLocality"                                                    
[114] "vernacularName"                                                      
[115] "year"                                                                
[116] "downloadDate"                                                        
```

Solucion a
=====================
class: small-code


```r
Sola <- Huemul %>% dplyr::select(lon, lat, basisOfRecord) %>% filter(!is.na(lat) & !is.na(lon))
kable(Sola)
```



|       lon|       lat|basisOfRecord      |
|---------:|---------:|:------------------|
| -72.93940| -49.37483|HUMAN_OBSERVATION  |
| -72.97712| -51.01511|HUMAN_OBSERVATION  |
| -71.87026| -46.08686|HUMAN_OBSERVATION  |
| -72.43751| -47.20485|HUMAN_OBSERVATION  |
| -73.01456| -51.03635|HUMAN_OBSERVATION  |
| -73.03190| -51.17531|HUMAN_OBSERVATION  |
| -72.72944| -46.25602|HUMAN_OBSERVATION  |
| -71.31538| -41.30110|PRESERVED_SPECIMEN |
| -71.31538| -41.30110|PRESERVED_SPECIMEN |
| -71.71667| -44.86667|PRESERVED_SPECIMEN |
| -71.71667| -44.86667|PRESERVED_SPECIMEN |
| -71.30989| -40.81978|PRESERVED_SPECIMEN |
| -71.31538| -41.30110|PRESERVED_SPECIMEN |
| -73.02467| -50.46476|PRESERVED_SPECIMEN |
| -71.33186| -41.26523|PRESERVED_SPECIMEN |
| -73.01764| -50.46747|PRESERVED_SPECIMEN |
| -71.70000| -45.26667|PRESERVED_SPECIMEN |
| -71.70000| -45.26667|PRESERVED_SPECIMEN |
| -71.70000| -45.26667|PRESERVED_SPECIMEN |
| -72.08000| -47.25000|PRESERVED_SPECIMEN |
| -72.00000| -41.50000|PRESERVED_SPECIMEN |
| -71.36714| -41.13574|PRESERVED_SPECIMEN |
| -71.71094| -42.75692|HUMAN_OBSERVATION  |
| -71.64718| -40.22605|PRESERVED_SPECIMEN |
| -67.88534| -43.99376|PRESERVED_SPECIMEN |

Solucion b
=====================
class: small-code


```r
Solb <- Huemul %>% group_by(basisOfRecord) %>% summarize(N = n())
kable(Solb)
```



|basisOfRecord      |   N|
|:------------------|---:|
|HUMAN_OBSERVATION  | 102|
|PRESERVED_SPECIMEN |  65|



Ejercicio 3
==================
incremental: true

* Entrar a [INE ambiental](http://www.ine.cl/estadisticas/medioambiente/series-cronologicas-vba) y bajar la base de datos de Dimensión Aire.
* Generar una base de datos **tidy** con las siguientes 5 columnas
    + El nombre de la localidad donde se encuntra la estación
    + El año en que se tomo la medida
    + El mes en que se tomo la medida
    + La temperatura media de ese mes
    + La media del mp25 de ese mes
    + Humedad relativa media mensual
    
Ejercicio 3 Continuado
==================

* De la base de datos anterior obterner un segundo data frame en la cual calculen para cada variable y estación la media y desviación estandar para cada mes
