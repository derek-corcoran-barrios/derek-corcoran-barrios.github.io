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

Clase 2: Investigación reproducible
========================================================
author: Derek Corcoran
date: "10/08, 2018"
autosize: true
transition: rotate

¿Que es investigación reproducible?
========================================================


- Código, datos (**Crudos**) y texto entrelazados
- en R: Rmarkdown (Rmd) y Rpresentation (Rpres) entre otros

![Peng](Reproducible.png)

Metas del día de hoy
========================================================

1.  Primer commit en github
2.  Un código en un chunk
3.  Un inline code
4.  Una tabla en el Rmarkdown
5.  Generar una primera exploración de datos con la base de datos


Github
========================================================

- Como "Google Drive" o "Dropbox" para código
- Control de cambios (Podemos volver a cualquier versión anterior)
- En base a codigo (idealmente), pero hay GUIs
- Cada proyecto es un repositorio

***
![plot of chunk unnamed-chunk-2](Octocat.png)


Crear primer repositorio
========================================================

- Crearse cuenta en github.com
- Crear repositorio en github

<img src="StartAProject.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" width="80%" style="display: block; margin: auto;" />


Crear primer repositorio
========================================================

<img src="NombreRepo.png" title="plot of chunk unnamed-chunk-4" alt="plot of chunk unnamed-chunk-4" width="80%" style="display: block; margin: auto;" />

Copiar la url
========================================================

<img src="GitAdress.png" title="plot of chunk unnamed-chunk-5" alt="plot of chunk unnamed-chunk-5" width="80%" style="display: block; margin: auto;" />

Volvamos a RStudio
========================================================

* Creamos un proyecto nuevo

<img src="NewProject.png" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" width="80%" style="display: block; margin: auto;" />

Pegamos la URL 
========================================================

<img src="GitRstudio.png" title="plot of chunk unnamed-chunk-7" alt="plot of chunk unnamed-chunk-7" width="80%" style="display: block; margin: auto;" />

La nueva pestaña git
========================================================

<img src="GitPan.png" title="plot of chunk unnamed-chunk-8" alt="plot of chunk unnamed-chunk-8" width="80%" style="display: block; margin: auto;" />

Los "¿tres?" pasos de un repositorio 
=============================

* **Git add:** Agregar a los archivos que vas a guardar
* **Git commit:** Guardar en el repositorio local (Mi computador)
* **Git push:** Guardar en el repositorio remoto (En la nube)

Git Add
========

* Sumar un archivo al repositorio
* ¿Cuando no hacerlo?
    + Limite de un archivo de 100 Mb
    + Límite de un repositorio de un Gb

<img src="GitAdd.png" title="plot of chunk unnamed-chunk-9" alt="plot of chunk unnamed-chunk-9" width="80%" style="display: block; margin: auto;" />

Git commit
========

* Con esto dices quiero guardar mis cambios en mi disco duro
* Se guarda en tu repositorio local (Tu computador)

<img src="Commit.png" title="plot of chunk unnamed-chunk-10" alt="plot of chunk unnamed-chunk-10" width="80%" style="display: block; margin: auto;" />

Mensaje del commit
========

* Debe ser relevante (ejemplo, no poner *Version final ahora si*)
* Si te equivocas puedes restablecer a cualquier commit anterior (si sabes cual es)

<img src="MensajeCommit.png" title="plot of chunk unnamed-chunk-11" alt="plot of chunk unnamed-chunk-11" width="80%" style="display: block; margin: auto;" />


A guardar el repositorio (git push)
========================================================

* Con esto subes tu commit a la nube (queda respaldado)

<img src="Push.png" title="plot of chunk unnamed-chunk-12" alt="plot of chunk unnamed-chunk-12" width="80%" style="display: block; margin: auto;" />

Reproducibilidad en R
========================================================

![Rep](Rmark.png)

***

1. Una carpeta
    + Datos crudos (csv, xls, html, json)
    + Codigo y texto (Rmd, Rpres, shiny)
    + Resultados (Manuscrito, Pagina Web, App)

Antes de empezar (importar datos)
=========================
incremental:true

* Hasta ahora hemos usado `data` (sólo para bases incorporadas en R)
* Dede hoy usaremos `read_csv` (Para csv, para otros archivos hay otras funciones)


Crear un nuevo Rmarkdown
========================================================

![NewRMD](https://archive.org/download/NewRmd/NewRmd.png)

Partes de un Rmd
========================================================
left: 30%

1. Texto
2. Cunks
3. Inline code
4. [Cheat sheet Rmd](https://www.rstudio.com/wp-content/uploads/2015/02/rmarkdown-cheatsheet.pdf)
5. El botón mágico **Knit**

***

![NewRMD](RMDexample.png)

Texto
========================================================
class: small-code

# Titulo

## subtitulo

*cursiva*

**negrita**

[link](https://stackoverflow.com/users/3808018/derek-corcoran)

***


```r
# Titulo

## subtitulo

*cursiva*

**negrita**

[link](https://stackoverflow.com/users/3808018/derek-corcoran)
```

Chunks
========================================================
incremental:true

![Chunk](Chunk.png)

+ *echo* = T o F muestro o no codigo
+ *message* = T o F muestra mensajes de paquetes
+ *warning* = T o F muestra advertencias 
+ *eval* = T o F evaluar o no el código
+ *cache* = T o F guarda o no el resultado
+ Para más opciones ver este [link](https://yihui.name/knitr/options/)


Inline code
========================================================

![Inline](Inline.png)

- Código entrelazado en el texto
- Para actualizar medias, máximos, mínimos
- Valores de p, diferencias estadísticas
- Pueden ser vectores, no tablas.

Ejemplo
========================================================

Pueden copiar el codigo de el siguiente [link](https://raw.githubusercontent.com/derek-corcoran-barrios/CursoR/master/Clase1/Sismos.Rmd), copiarlo en un archivo rmd, apretar knit y debieran ver algo como esto:

- Otro [ejemplo](http://ec2-18-191-191-69.us-east-2.compute.amazonaws.com:3838/WhereToLive/)

![Terremotos](ExampleShown.png)

Ejercicio 1
==============================
incremental: true

* Usando la base de datos *iris* crea un inline code que diga cuál es la media del largo del pétalo de la especie *Iris virginica*
    + solución:
    + la media para I. virginica es 5.552
    + "la media para I. virginica es "r mean((iris %>% filter(Species == "virginica"))$Petal.Length)""


Tablas: Kable
========================================================

- kable parte de knitr, tabla igual a lo ingresado 
- [stargazer](https://cran.r-project.org/web/packages/stargazer/vignettes/stargazer.pdf), comparación de modelos
- otras opciones como texreg


Armemos nuestras propias tablas!!!
========================================================

![Tabla](http://www.chemicalprocessing.com/assets/Media/0908/cartoon_0906.jpg)

