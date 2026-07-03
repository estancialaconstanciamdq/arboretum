# Capa GIS del Arboretum

El mapa (`mapa.qmd`) carga **automáticamente** cualquiera de estos archivos
si está presente en esta carpeta. No hay que tocar código: alcanza con
exportarlos desde QGIS con estos nombres exactos y volver a renderizar.

| Archivo                        | Contenido           | Geometría   | Se dibuja como            |
|--------------------------------|---------------------|-------------|---------------------------|
| `limite_arboretum.geojson`     | Límite de la propiedad | Polígono | contorno marrón           |
| `senderos.geojson`             | Senderos / caminos  | Líneas      | líneas ocre               |
| `sectores.geojson`             | Sectores / colecciones | Polígonos | relleno verde translúcido |
| `lagunas.geojson`              | Lagunas / espejos de agua | Polígonos | relleno azul translúcido  |

## Cómo exportar desde QGIS

1. Dibujá cada capa (o importá la que tengas).
2. Clic derecho sobre la capa → **Exportar → Guardar objetos como…**
3. Formato: **GeoJSON**.
4. **CRS: EPSG:4326 (WGS 84)** — importante: Leaflet trabaja en lat/long.
5. Guardá con el nombre exacto de la tabla de arriba, dentro de `gis/`.

Cada capa nueva aparece como una casilla activable en el control de capas
del mapa. Podés empezar por `limite_arboretum.geojson` y agregar el resto
cuando quieras.
