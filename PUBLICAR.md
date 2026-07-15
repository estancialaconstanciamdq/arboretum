# Cómo publicar el sitio (render + push a GitHub)

Cada vez que edités los archivos `.qmd` o los datos, seguí estos pasos desde la
carpeta del proyecto (`ArboretumMap`).

## Opción A — desde la Terminal
(En RStudio: pestaña **Terminal**. O Git Bash / PowerShell en la carpeta del proyecto.)

```bash
quarto render                       # 1. Genera/actualiza la carpeta docs/ con el sitio
git add -A                          # 2. Prepara todos los cambios
git commit -m "Actualizo el sitio"  # 3. Guarda el cambio (poné el mensaje que quieras)
git push                            # 4. Sube a GitHub (rama main)
```

En 1–2 minutos GitHub Pages publica la versión nueva.

## Opción B — desde RStudio (sin escribir comandos)

1. Pestaña **Build** → **Render Website** (equivale a `quarto render`).
2. Pestaña **Git** → tildá los archivos cambiados → **Commit** → escribí el mensaje → **Push**.

## Recordatorios importantes

- **Verificá que el render termine SIN errores** antes de pushear. Si se corta a la
  mitad (por ejemplo por un error en una página), quedan páginas sin generar y en el
  sitio dan 404.
- **Nunca edites la carpeta `docs/` a mano**: se regenera completa con cada render.
- Los archivos nuevos (imágenes, PDFs, páginas) entran igual con `git add -A`.
- Si en algún momento el sitio no toma un archivo, suele ser tema de
  **mayúsculas/minúsculas** en el nombre (GitHub distingue `Foto.jpg` de `foto.jpg`).

## Nota sobre GitHub Actions (opcional)

El proyecto incluye `.github/workflows/publish.yml`. Si está activo, al hacer `push`
a `main` GitHub también renderiza el sitio en el servidor. Podés ver el progreso en
la pestaña **Actions** del repositorio (tilde verde = publicado).
