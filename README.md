# Repositorio del Curso [Aprende a analizar los datos del COVID-19 con R y Python](https://cursos.frogamesformacion.com/courses/covid-19/)

## Instalación de R y Python

Se ha utilizado `R 4.2.1 Patched`, y que se puede descargar en el siguiente [link](https://cran.r-project.org/bin/windows/base/R-4.2.1patched-win.exe).

Instalación entorno virtual con Anaconda con la librería pandas (Opcional):

```bash
conda create -n covid19 python=3.9 pandas
```

Durante el curso no se emplea en ningún momento `Python`, por lo que se puede prescindir de crear un entorno virtual para el curso. No obstante, es recomendable para tener la posibilidad de juntar `R` con `Python` en el análisis del COVID-19.

## Consideraciones a tener en cuenta

* Los RMarkdown de la carpeta [presentaciones](https://github.com/jmudy/covid19/tree/curso/presentaciones) no han sido modificados con mi configuración. Solo he empleado los ficheros `.html` como apoyo durante el curso.

* Los datos utilizados en `Fuentes_de_datos.Rmd` de la carpeta [extra](https://github.com/jmudy/covid19/tree/curso/extra) utiliza datos COVID-19 en España no actualizados (contienen datos hasta abril 2020). En el RMarkdown `Analisis_COVID19.Rmd` sí que se ha empleado un dataset actualizado al día de escribir el código (agosto 2022).
