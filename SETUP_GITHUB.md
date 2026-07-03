# Sincronización con GitHub y publicación automática

Repositorio: https://github.com/estancialaconstanciamdq/arboretumdatalab
Rama principal: `main`

## Paso 1 — Subir todo lo trabajado (sincronizar ahora)

Todos los cambios ya están en tu carpeta local. Desde la **Terminal** de RStudio
(en la carpeta del proyecto):

```bash
quarto render          # refresca la carpeta docs/ que hoy publica el sitio
git add -A
git commit -m "Atlas del Arboretum: fichas automáticas, catálogo, mapa, estadísticas, aves, datos"
git push
```

Con esto, el sitio en vivo (que hoy se sirve desde la carpeta `docs/`) se actualiza
de inmediato, y además queda subido el flujo de publicación automática (paso 2).

## Paso 2 — Activar la publicación automática (una sola vez)

Al hacer el `push`, se ejecuta el flujo `.github/workflows/publish.yml`, que en la
nube instala R + Quarto, **regenera las fichas** y **renderiza el sitio**, y lo
publica en una rama llamada `gh-pages`.

Después de que la primera ejecución termine con éxito (pestaña **Actions** del
repositorio), activá esa rama como fuente:

1. GitHub → repositorio → **Settings** → **Pages**
2. En **Build and deployment → Source**: elegí **Deploy from a branch**
3. Branch: **`gh-pages`** · carpeta **`/ (root)`** → **Save**

Desde ese momento, el ciclo es simplemente:

> editar `data/Arboretum_Master.xlsx` → `git push` → **el sitio se reconstruye solo**

Ya no hace falta renderizar a mano. `quarto preview` sigue sirviendo para ver los
cambios localmente antes de subirlos.

## Nota

- El flujo instala en la nube los paquetes de R necesarios
  (`readxl`, `dplyr`, `ggplot2`, `leaflet`, …), así que la publicación no depende
  de lo que tengas instalado en tu computadora.
- Una vez que `gh-pages` publique bien, la carpeta `docs/` deja de ser necesaria en
  el repositorio; podés dejar de versionarla más adelante si querés (opcional).
