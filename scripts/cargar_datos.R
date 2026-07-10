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
