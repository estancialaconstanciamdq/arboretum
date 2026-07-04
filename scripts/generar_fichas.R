# ---------------------------------------------------------------------------
# generar_fichas.R
# Generates one species profile page (ficha) per tree row in the master
# workbook. Run automatically before every render via the `pre-render`
# hook in _quarto.yml, so pages are NEVER edited by hand.
#
#   One Excel row  ->  one fichas/<slug>.qmd
#
# Empty fields are simply omitted from the page (graceful degradation), so
# the site can be published now and fill itself in as the database grows.
# ---------------------------------------------------------------------------

source("scripts/cargar_datos.R")   # gives us `arboles` (with `slug`) + helpers

dir_fichas <- "fichas"
if (!dir.exists(dir_fichas)) dir.create(dir_fichas, recursive = TRUE)

# --- Small builders --------------------------------------------------------

# YAML-safe title text (escape embedded quotes)
yaml_title <- function(x) gsub('"', "'", x)

# One "**Label:** value" line, or "" when the value is empty
campo <- function(etiqueta, valor, italic = FALSE, sufijo = "") {
  if (!tiene_valor(valor)) return("")
  v <- trimws(as.character(valor))
  if (italic) v <- paste0("*", v, "*")
  paste0("**", etiqueta, ":** ", v, sufijo, "\n\n")
}

# Planting year comes in as numeric (2004) -> print without decimals
fmt_anio <- function(x) if (tiene_valor(x)) as.character(as.integer(x)) else x

construir_ficha <- function(t) {
  titulo <- if (tiene_valor(t$nombre_comun)) t$nombre_comun
            else if (tiene_valor(t$nombre_cientifico)) t$nombre_cientifico
            else t$ID

  partes <- c()
  add <- function(x) if (nzchar(x)) partes[[length(partes) + 1]] <<- x

  # Header comment marking the file as generated
  add(sprintf(
    "<!-- ARCHIVO GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.\n     Fuente: data/Arboretum_Master.xlsx (fila %s).\n     Para cambiar esta página, editá el Excel y volvé a renderizar. -->\n",
    t$ID
  ))

  # YAML front matter
  add(sprintf("---\ntitle: \"%s\"\nformat: html\n---\n", yaml_title(titulo)))

  # Photo
  if (tiene_valor(t$foto)) {
    add(sprintf(
      "![](../fotos/%s){style=\"max-width:320px; border-radius:10px;\"}\n",
      trimws(t$foto)
    ))
  }

  # Identity / taxonomy
  add(campo("Nombre científico", t$nombre_cientifico, italic = TRUE))
  add(campo("Familia",           t$familia))

  # Origin
  add(campo("Origen",     t$origen))
  add(campo("Continente", t$continente))

  # Life / management data
  add(campo("Año de plantación", fmt_anio(t$año_plantacion)))
  add(campo("Altura",            t$altura_m,          sufijo = " m"))
  add(campo("Diámetro de tronco",t$diametro_cm,       sufijo = " cm"))
  add(campo("Estado sanitario",  t$estado_sanitario))
  add(campo("Sector",            t$sector))

  # Phenology
  add(campo("Floración",      t$floracion))
  add(campo("Fructificación", t$fructificacion))

  # Observations
  if (tiene_valor(t$observaciones)) {
    add(sprintf("## Observaciones\n\n%s\n", trimws(t$observaciones)))
  }

  # Captura de carbono (aparece cuando hay diámetro cargado)
  if ("co2_kg" %in% names(t) && !is.na(t$co2_kg)) {
    add(sprintf(
      "## Captura de carbono\n\nEste ejemplar almacena aproximadamente **%s kg de CO₂** (estimación).\n",
      format(round(t$co2_kg), big.mark = ".", decimal.mark = ",")
    ))
  }

  # Location
  if (tiene_valor(t$latitud) && tiene_valor(t$longitud)) {
    add(sprintf(
      "## Ubicación\n\nCoordenadas: %s, %s\n\n[Ver en el mapa »](../mapa.qmd)\n",
      t$latitud, t$longitud
    ))
  }

  # Código QR (si existe la imagen generada por scripts/generar_qr.py)
  qr_rel <- file.path("qr", paste0(t$slug, ".png"))
  if (file.exists(qr_rel)) {
    add(sprintf(
      "## Código QR\n\n![Código QR de la ficha](../qr/%s.png){width=130}\n\nEscaneá para abrir esta ficha en el celular.\n",
      t$slug
    ))
  }

  # Padrinazgo (si existe la columna 'padrino' y tiene valor)
  if ("padrino" %in% names(t) && tiene_valor(t$padrino)) {
    add(sprintf(
      "## Padrino / Madrina\n\n> 🌳 Este ejemplar fue apadrinado por **%s**.\n> ¡Gracias por apoyar la conservación del arboretum!\n\n[¿Querés apadrinar un árbol? »](../apadrina.qmd)\n",
      trimws(t$padrino)
    ))
  }

  # Footer
  add("---\n\n[« Volver a las especies](../especies.qmd)\n")

  paste(partes, collapse = "\n")
}

# --- Generate --------------------------------------------------------------

n <- 0
for (i in seq_len(nrow(arboles))) {
  t <- arboles[i, ]
  destino <- file.path(dir_fichas, paste0(t$slug, ".qmd"))
  writeLines(construir_ficha(t), destino, useBytes = TRUE)
  n <- n + 1
}

cat(sprintf("generar_fichas.R: %d fichas generadas en '%s/'.\n", n, dir_fichas))
