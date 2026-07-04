# ---------------------------------------------------------------------------
# exportar_datos.R
# Exporta las hojas del libro maestro a CSV (UTF-8) en la carpeta datos/,
# para descarga pública. Corre como pre-render, junto con generar_fichas.R.
# ---------------------------------------------------------------------------

source("scripts/cargar_datos.R")

dir_datos <- "datos"
if (!dir.exists(dir_datos)) dir.create(dir_datos, recursive = TRUE)

exportar <- function(df, nombre) {
  ruta <- file.path(dir_datos, nombre)
  write.csv(df, ruta, row.names = FALSE, fileEncoding = "UTF-8", na = "")
  ruta
}

# Exportar solo registros con contenido real
aves_pub <- dplyr::filter(aves, tiene_valor(especie))

exportar(arboles,  "arboles.csv")
exportar(aves_pub, "aves.csv")
exportar(puntos,   "puntos_de_interes.csv")

cat(sprintf("exportar_datos.R: CSV exportados a '%s/' (arboles: %d, aves: %d, puntos: %d).\n",
            dir_datos, nrow(arboles), nrow(aves_pub), nrow(puntos)))
