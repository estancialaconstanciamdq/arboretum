# ---------------------------------------------------------------------------
# generar_fichas_en.R
# English profile pages (fichas). Mirrors generar_fichas.R but writes to
# en/fichas/<slug>.qmd with English labels and paths adjusted for the deeper
# folder. Run via the `pre-render` hook after the Spanish generator.
#
#   One Excel row  ->  one en/fichas/<slug>.qmd
# ---------------------------------------------------------------------------

source("scripts/cargar_datos.R")   # gives us `arboles` (with `slug`) + helpers

dir_fichas_en <- file.path("en", "fichas")
if (!dir.exists(dir_fichas_en)) dir.create(dir_fichas_en, recursive = TRUE)

# English labels for life-form (data values are in Spanish)
tr_forma_en <- c("Conífera"="Conifer", "Árbol latifoliado"="Broadleaf tree",
                 "Arbusto"="Shrub", "Palmera"="Palm", "Otro"="Other")
forma_en <- function(x) { o <- unname(tr_forma_en[as.character(x)]); ifelse(is.na(o), as.character(x), o) }

yaml_title <- function(x) gsub('"', "'", x)

campo <- function(etiqueta, valor, italic = FALSE, sufijo = "") {
  if (!tiene_valor(valor)) return("")
  v <- trimws(as.character(valor))
  if (italic) v <- paste0("*", v, "*")
  paste0("**", etiqueta, ":** ", v, sufijo, "\n\n")
}

fmt_anio <- function(x) if (tiene_valor(x)) as.character(as.integer(x)) else x

# Shared English nav bar (paths are relative to en/fichas/<slug>.html)
nav_en <- function(slug) paste0(
  "```{=html}\n",
  "<style>#quarto-header,.navbar{display:none !important;}</style>\n",
  "<div class=\"en-nav\">\n",
  "  <span class=\"brand\">Arboretum</span>\n",
  "  <a href=\"../index.html\">Home</a>\n",
  "  <a href=\"../collection.html\">The Collection</a>\n",
  "  <a href=\"../map.html\">Map</a>\n",
  "  <a href=\"../wellbeing.html\">Wellbeing</a>\n",
  "  <a href=\"../visit.html\">Visit</a>\n",
  "  <a href=\"../sponsor.html\">Sponsor a tree</a>\n",
  "  <a href=\"../companies.html\">Companies</a>\n",
  "  <a href=\"../contact.html\">Contact</a>\n",
  "  <span class=\"spacer\"></span>\n",
  "  <a href=\"../experiences.html\" class=\"cta\">Book a visit</a>\n",
  "  <a href=\"../../fichas/", slug, ".html\" class=\"lang\">Español &#9656;</a>\n",
  "</div>\n",
  "```\n"
)

construir_ficha <- function(t) {
  titulo <- if (tiene_valor(t$nombre_comun)) t$nombre_comun
            else if (tiene_valor(t$nombre_cientifico)) t$nombre_cientifico
            else t$ID

  partes <- c()
  add <- function(x) if (nzchar(x)) partes[[length(partes) + 1]] <<- x

  add(sprintf(
    "<!-- AUTO-GENERATED FILE — DO NOT EDIT BY HAND.\n     Source: data/Arboretum_Master.xlsx (row %s).\n     To change this page, edit the Excel file and re-render. -->\n",
    t$ID
  ))

  add(sprintf("---\ntitle: \"%s\"\nformat: html\n---\n", yaml_title(titulo)))

  add(nav_en(t$slug))

  if (tiene_valor(t$foto)) {
    add(sprintf(
      "![](../../fotos/%s){style=\"max-width:320px; border-radius:10px;\"}\n",
      trimws(t$foto)
    ))
  }

  add(campo("Scientific name", sci_html(t$nombre_cientifico, t$autor), italic = FALSE))
  add(campo("Family",          t$familia))
  add(campo("Type",            forma_en(t$forma_vida)))

  add(campo("Origin",     t$origen))
  add(campo("Continent",  t$continente))

  add(campo("Planting year",  fmt_anio(t$año_plantacion)))
  add(campo("Height",         t$altura_m,     sufijo = " m"))
  add(campo("Trunk diameter", t$diametro_cm,  sufijo = " cm"))
  add(campo("Health status",  t$estado_sanitario))
  add(campo("Sector",         t$sector))

  add(campo("Flowering", t$floracion))
  add(campo("Fruiting",  t$fructificacion))

  if (tiene_valor(t$observaciones)) {
    add(sprintf("## Notes\n\n%s\n", trimws(t$observaciones)))
  }

  if ("co2_kg" %in% names(t) && !is.na(t$co2_kg)) {
    add(sprintf(
      "## Carbon capture\n\nThis specimen stores approximately **%s kg of CO₂** (estimate).\n",
      format(round(t$co2_kg), big.mark = ",", decimal.mark = ".")
    ))
  }

  if (tiene_valor(t$latitud) && tiene_valor(t$longitud)) {
    add(sprintf(
      "## Location\n\nCoordinates: %s, %s\n\n[See on the map »](../map.qmd)\n",
      t$latitud, t$longitud
    ))
  }

  qr_rel <- file.path("qr", paste0(t$slug, ".png"))
  if (file.exists(qr_rel)) {
    add(sprintf(
      "## QR code\n\n![QR code for this profile](../../qr/%s.png){width=130}\n\nScan to open this profile on your phone.\n",
      t$slug
    ))
  }

  if ("padrino" %in% names(t) && tiene_valor(t$padrino)) {
    add(sprintf(
      "## Sponsor\n\n> \U0001F333 This specimen is sponsored by **%s**.\n> Thank you for supporting the conservation of the arboretum!\n\n[Would you like to sponsor a tree? »](../sponsor.qmd)\n",
      trimws(t$padrino)
    ))
  }

  add("---\n\n[« Back to featured species](../species.qmd)\n")

  paste(partes, collapse = "\n")
}

n <- 0
for (i in seq_len(nrow(arboles))) {
  t <- arboles[i, ]
  destino <- file.path(dir_fichas_en, paste0(t$slug, ".qmd"))
  writeLines(construir_ficha(t), destino, useBytes = TRUE)
  n <- n + 1
}

cat(sprintf("generar_fichas_en.R: %d English fichas generated in '%s/'.\n", n, dir_fichas_en))
