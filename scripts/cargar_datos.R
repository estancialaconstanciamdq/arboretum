library(readxl)
library(dplyr)

archivo <- "data/Arboretum_Master.xlsx"

arboles <- read_excel(
  archivo,
  sheet = "Árboles"
)

aves <- read_excel(
  archivo,
  sheet = "Aves"
)

puntos <- read_excel(
  archivo,
  sheet = "Puntos de interés"
)

# eliminar puntos sin coordenadas

puntos <- puntos %>%
  filter(
    latitud != "...",
    longitud != "..."
  ) %>%
  mutate(
    latitud = as.numeric(latitud),
    longitud = as.numeric(longitud)
  )

