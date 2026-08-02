# ---------------------------------------------------------------------------
# cargar_datos.R
# Single source of truth for reading the master workbook.
# Sourced by: mapa.qmd, especies.qmd, scripts/generar_fichas.R
# Working directory is always the project root (Quarto renders from there).
# ---------------------------------------------------------------------------

suppressMessages({
  library(readxl)
  library(dplyr)
})

archivo <- "data/Arboretum_Master.xlsx"

# --- Helpers ---------------------------------------------------------------

# TRUE when a value carries real information (not NA / blank / placeholder)
tiene_valor <- function(x) {
  !is.na(x) & !(trimws(as.character(x)) %in% c("", "-", "...", "NA"))
}

# Turn a label into a safe, accent-free URL slug: "Cedro del Himalaya" -> "cedro-del-himalaya"
slugify <- function(x) {
  x <- as.character(x)
  x <- iconv(x, to = "ASCII//TRANSLIT")   # strip accents
  x <- tolower(x)
  x <- gsub("[^a-z0-9]+", "-", x)          # non-alphanumeric -> hyphen
  x <- gsub("(^-+|-+$)", "", x)            # trim leading/trailing hyphens
  x
}

# Nombre científico con cursiva correcta: solo el binomio (género + epíteto)
# va en cursiva; el autor va en redonda. Maneja "sp."/"spp.", híbridos (×) y
# rangos infraespecíficos (subsp., var., f., …). `autor` opcional (redonda).
sci_html <- function(nombre, autor = NA) {
  n <- length(nombre)
  if (length(autor) == 1L) autor <- rep(autor, n)
  esc1 <- function(t) { t <- gsub("&", "&amp;", t, fixed = TRUE)
                        t <- gsub("<", "&lt;",  t, fixed = TRUE)
                        gsub(">", "&gt;", t, fixed = TRUE) }
  ital <- function(t) paste0("<i>", esc1(t), "</i>")
  ranks  <- c("subsp.","ssp.","var.","f.","fma.","cv.","forma","nothosubsp.","nothovar.")
  sinesp <- c("sp.","spp.","sp")
  vapply(seq_len(n), function(k) {
    x <- nombre[k]
    if (!tiene_valor(x)) return("")
    toks <- strsplit(trimws(as.character(x)), "\\s+")[[1]]
    m <- length(toks); if (m == 0) return("")
    out <- ital(toks[1]); i <- 2
    if (i <= m) {
      t2 <- toks[i]
      if (t2 %in% sinesp) { out <- c(out, esc1(t2)); i <- i + 1 }
      else if (tolower(t2) %in% c("cf.","aff.","x","×") && i + 1 <= m) {
        out <- c(out, esc1(t2), ital(toks[i + 1])); i <- i + 2
      } else { out <- c(out, ital(t2)); i <- i + 1 }
    }
    while (i <= m) {
      t <- toks[i]
      if (tolower(t) %in% ranks && i + 1 <= m) { out <- c(out, esc1(t), ital(toks[i + 1])); i <- i + 2 }
      else { out <- c(out, esc1(t)); i <- i + 1 }
    }
    res <- paste(out, collapse = " ")
    a <- autor[k]
    if (!is.na(a) && tiene_valor(a)) res <- paste0(res, " ", esc1(trimws(as.character(a))))
    res
  }, character(1))
}

# --- Read sheets -----------------------------------------------------------

# Resolve sheet names by a distinctive ASCII fragment, so accents / file
# encoding never break the match across operating systems.
.hojas <- excel_sheets(archivo)
.hoja <- function(patron) {
  h <- .hojas[grepl(patron, .hojas, ignore.case = TRUE)][1]
  if (is.na(h)) stop("No se encontró la hoja que coincide con: ", patron)
  h
}

arboles <- read_excel(archivo, sheet = .hoja("rbol"))    # Árboles
aves    <- read_excel(archivo, sheet = .hoja("^aves"))   # Aves
puntos  <- read_excel(archivo, sheet = .hoja("inter"))   # Puntos de interés

# Remove points without coordinates
puntos <- puntos %>%
  filter(latitud != "...", longitud != "...") %>%
  mutate(
    latitud  = as.numeric(latitud),
    longitud = as.numeric(longitud)
  )

# --- Assign a stable, unique slug to every tree ----------------------------
# Preference order: hand-set `ficha` slug -> slug from common name -> tree ID.
# Any slug that would collide is disambiguated with the ID, so the filename
# is ALWAYS unique even when two specimens share a name (e.g. two araucarias).

arboles <- arboles %>%
  mutate(
    .base = dplyr::case_when(
      tiene_valor(ficha)        ~ slugify(ficha),
      tiene_valor(nombre_comun) ~ slugify(nombre_comun),
      TRUE                      ~ tolower(ID)
    )
  ) %>%
  group_by(.base) %>%
  mutate(
    slug = if (n() > 1) paste0(.base, "-", tolower(ID)) else .base
  ) %>%
  ungroup() %>%
  select(-.base)

# --- Estimación de carbono ------------------------------------------------
# Se completa automáticamente a medida que se cargan diámetros (diametro_cm,
# medido como DAP: diámetro a la altura del pecho) y, si está, la altura_m.
# Es una ESTIMACIÓN educativa, no un inventario de carbono certificado.
#
#  Biomasa aérea (AGB), Chave et al. (2014):
#    AGB = 0.0673 * (rho * D^2 * H)^0.976
#  Si no hay altura medida, se estima con H ≈ 1.6 * sqrt(D) (relación genérica).
#  Carbono = AGB * 0.47 (fracción IPCC).   CO2 = Carbono * 3.667.

DENSIDAD_MADERA <- 0.60   # g/cm3, valor medio genérico (ajustable)

estimar_agb_kg <- function(diametro_cm, altura_m, rho = DENSIDAD_MADERA) {
  d <- suppressWarnings(as.numeric(diametro_cm))
  h <- suppressWarnings(as.numeric(altura_m))
  h_use <- ifelse(!is.na(h) & h > 0, h, 1.6 * sqrt(d))   # altura medida o estimada
  agb <- rep(NA_real_, length(d))
  ok  <- !is.na(d) & d > 0
  agb[ok] <- 0.0673 * (rho * d[ok]^2 * h_use[ok])^0.976
  agb
}

arboles$agb_kg     <- estimar_agb_kg(arboles$diametro_cm, arboles$altura_m)
arboles$carbono_kg <- arboles$agb_kg * 0.47
arboles$co2_kg     <- arboles$carbono_kg * 3.667

# --- Estado de conservación (Lista Roja de la UICN) ------------------------
# Búsqueda curada por binomio (género + epíteto). Solo se etiquetan especies
# cuya categoría fue verificada; el resto queda sin insignia (degradación
# elegante). Fuente: IUCN Red List of Threatened Species (iucnredlist.org).
# Códigos: EN = En peligro, VU = Vulnerable, NT = Casi amenazada,
#          LC = Preocupación menor. Verificado: julio 2025.

IUCN_CAT <- c(
  # En peligro (EN)
  "sequoiadendron giganteum" = "EN",
  "sequoia sempervirens"     = "EN",
  "cedrus atlantica"         = "EN",
  "pinus radiata"            = "EN",
  "ginkgo biloba"            = "EN",
  # Vulnerable (VU)
  "aesculus hippocastanum"   = "VU",
  # Casi amenazada (NT)
  "chamaecyparis lawsoniana" = "NT",
  "cryptomeria japonica"     = "NT",
  # Preocupación menor (LC)
  "cedrus deodara"           = "LC",
  "quercus robur"            = "LC",
  "quercus rubra"            = "LC",
  "quercus baloot"           = "LC",
  "fagus sylvatica"          = "LC",
  "abies concolor"           = "LC",
  "magnolia grandiflora"     = "LC",
  "nothofagus dombeyi"       = "LC",
  "nothofagus obliqua"       = "LC",
  "araucaria bidwillii"      = "LC",
  "taxodium mucronatum"      = "LC",
  "eucalyptus globulus"      = "LC",
  "liriodendron tulipifera"  = "LC",
  "ilex aquifolium"          = "LC",
  "calocedrus decurrens"     = "LC"
)

# Extrae el binomio (género + epíteto en minúsculas) de un nombre científico,
# ignorando autor, "sp."/"spp.", híbridos y rangos infraespecíficos.
binomio <- function(nombre) {
  vapply(nombre, function(x) {
    if (!tiene_valor(x)) return("")
    x <- iconv(trimws(as.character(x)), to = "ASCII//TRANSLIT")
    x <- gsub("[^A-Za-z ]", " ", x)              # quita ?, `, dígitos, etc.
    toks <- strsplit(tolower(trimws(x)), "\\s+")[[1]]
    if (length(toks) < 2) return("")
    if (toks[2] %in% c("sp", "spp", "x", "cf", "aff")) return("")
    paste(toks[1], toks[2])
  }, character(1), USE.NAMES = FALSE)
}

# Devuelve el código UICN de un nombre científico ("" si no está en la lista).
iucn_de <- function(nombre) {
  b <- binomio(nombre)
  out <- unname(IUCN_CAT[b])
  ifelse(is.na(out), "", out)
}

# Etiqueta legible de una categoría, en español o inglés.
iucn_label <- function(code, lang = "es") {
  es <- c(EN = "En peligro", VU = "Vulnerable", NT = "Casi amenazada",
          LC = "Preocupación menor")
  en <- c(EN = "Endangered", VU = "Vulnerable", NT = "Near Threatened",
          LC = "Least Concern")
  dic <- if (lang == "en") en else es
  out <- unname(dic[code]); ifelse(is.na(out), "", out)
}

# Insignia HTML de conservación (vacía si no hay categoría).
iucn_badge <- function(code, lang = "es") {
  vapply(seq_along(code), function(i) {
    cc <- code[i]
    if (is.na(cc) || !nzchar(cc)) return("")
    lab <- iucn_label(cc, lang)
    sprintf("<span class=\"iucn-badge iucn-%s\" title=\"UICN/IUCN: %s\">%s · %s</span>",
            cc, lab, cc, lab)
  }, character(1))
}

arboles$iucn <- iucn_de(arboles$nombre_cientifico)
