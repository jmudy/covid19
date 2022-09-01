# Repositorio del Curso [Aprende a analizar los datos del COVID-19 con R y Python](https://cursos.frogamesformacion.com/courses/covid-19/)

## Instalación de R y Python

Se ha utilizado `R 4.2.1 Patched`, y que se puede descargar en el siguiente [link](https://cran.r-project.org/bin/windows/base/R-4.2.1patched-win.exe).

Instalación entorno virtual con Anaconda con la librería pandas (Opcional):

```bash
conda create -n covid19 python=3.9 pandas
```

Durante el curso no se emplea en ningún momento `Python`, por lo que se puede prescindir de crear un entorno virtual para el curso. No obstante, es recomendable para tener la posibilidad de juntar `R` con `Python` en el análisis del COVID-19.

## Consideraciones a tener en cuenta

* El RMarkdown `EstudioChi2.Rmd` no ha sido modificado con mi configuración ya que me saltaban errores que no he podido solucionar. Solo he empleado el fichero `.html` como apoyo durante el curso.

* He eliminado los scripts de `R` del repo original ya que no me funcionaba ninguno de ellos, me saltaban errores que no he podido solucionar.

* Los datos utilizados en `Fuentes_de_datos.Rmd` utiliza datos COVID-19 en España no actualizados (contienen datos hasta abril 2020). En el resto de RMarkdowns sí que se ha empleado un dataset actualizado al día de escribir el código (agosto 2022).
