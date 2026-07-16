# Hoja de ruta de mejoras — Arboretum (basada en el benchmark de arboretums)

Estado actualizado del listado original (Canberra, Arnold/Harvard, Morton, Chicago,
Brooklyn). Marca qué ya está hecho, qué está en curso y qué queda.

---

## ✅ Ya implementado

- **Página "Visitá el arboretum"** — planificación de visita (cómo llegar, reserva, qué llevar, FAQs).
- **Buscador + filtros en el Mapa** — buscar especie por nombre (JavaScript puro, sin dependencias) + filtro por tipo con las capas.
- **Descarga del catálogo en CSV** — datos abiertos, se regenera solo en cada render.
- **Calendario natural de aves** — filtro por estación (primavera/verano/otoño/invierno) a partir de los datos existentes.
- **Sección Voluntariado** — programa en formación + diseño del formulario de inscripción.
- **Hero del home** — foto real inmersiva con título y lema en vivo (reemplazó la imagen vieja "Data Lab").
- **Página de Eventos de Empresa** — foco corporativo, con fotos reales (aéreas, etc.) y el diferencial "evento con propósito".
- **Íconos del mapa** — marcadores propios (árboles, coníferas, aves, puntos, apadrinados).

## 🔨 En curso / esperando algo tuyo

- **Newsletter** — base ya consolidada (86 contactos). Falta: crear cuenta Brevo, importar el CSV y que arme el **formulario de captura** en el sitio.
- **Instagram** — hay botón "Seguir" en Eventos. Falta (si querés) el **feed embebido en vivo** en home/contacto (necesita un widget o URLs de posteos).
- **Testimonios** — vos los buscás y los maqueto como bloque de citas.
- **Eventos: completar datos** — capacidad al aire libre, gastronomía/catering, servicios; y sumar una foto de "gente en evento" si aparece.

## 🎯 Pendientes — Fáciles (bajo esfuerzo)

- **Botón de donación** — un "Donar" visible (necesito un link de Mercado Pago).
- **Franja de prensa / reconocimientos / aliados** — logos o menciones que refuercen credibilidad.
- **"Qué ver esta temporada"** — recuadro rotativo; semi-automatizable con las columnas `floración`/`fructificación` del Excel.
- **Completar la página Visitá** — llenar horarios, precios, estacionamiento, accesibilidad, mascotas (placeholders ya marcados).
- **Recorridos autoguiados en PDF** — uno o dos folletos descargables (nativas, aves, sensorial).
- **Usar las fotos macro** (picaflor, coníferas) vinculadas a sus especies en Aves/Flora.

## 🎯 Pendientes — Comerciales (alto impacto)

- **"Amigos del Arboretum" (membresía)** — ingreso recurrente; página tipo Voluntariado.
- **Apadriná como producto con pago online** — hoy dice "escribinos"; sumar pago por nivel (Mercado Pago) baja la fricción.
- **Claridad de reserva + precios** — que "Reservar visita" sea un embudo claro con qué incluye y desde cuánto.
- **Novedades / blog (SEO)** — notas cortas de temporada; posicionan en Google y traen visitas nuevas.

## 🎯 Pendientes — Ambiciosas (diferenciación)

- **Ciencia ciudadana** — integración con iNaturalist / eBird para observaciones de visitantes.
- **Mapa en el lugar** — optimización mobile + geolocalización "estás acá" + recorrido con audio.
- **Accesibilidad** — info física + revisión de accesibilidad web + versión en inglés (home / plan your visit).
- **Datos citables** — publicar la colección como dataset con DOI; a futuro, red de fenología con sensores.

---

## Sugerencia de orden para seguir

1. **Cerrar Newsletter** (formulario de captura, apenas tengas Brevo).
2. **Amigos del Arboretum + botón de donación** (comercial, fácil).
3. **Testimonios** (cuando los tengas) + **franja de aliados/prensa**.
4. **Completar Eventos y Visitá** con los datos reales.
5. **"Qué ver esta temporada"** aprovechando los datos de floración.
