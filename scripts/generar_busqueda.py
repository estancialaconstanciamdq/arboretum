"""
generar_busqueda.py
Genera dos "Búsquedas del tesoro" (Primaria y Secundaria) en LaTeX, listas para
imprimir. Las consignas están pensadas sobre lo que realmente hay en el arboretum.

Uso:   python scripts/generar_busqueda.py
Salida: busqueda_primaria.tex , busqueda_secundaria.tex  (compilar con pdflatex)
"""
import os

LOGO = "fotos/logo_lc.jpg"

PRIMARIA = [
    "Un árbol muy alto (mirá bien hacia arriba).",
    "Una conífera: tiene hojas como agujas o escamas.",
    "Una hoja más grande que tu mano.",
    "Un tronco con corteza rugosa o que se descama.",
    "Un ave posada o volando.",
    "Un fruto, una piña o una semilla en el suelo.",
    "Un árbol con hojas de colores de otoño.",
    "Una palmera.",
    "Un árbol con flores.",
    "Tu árbol favorito: dibujá su hoja al dorso de la hoja.",
]

SECUNDARIA = [
    "Una conífera y una latifoliada: anotá una diferencia entre ellas.",
    "Un árbol de la familia Fagaceae (los robles).",
    "Una especie originaria de Asia.",
    "Una especie originaria de Oceanía (Australia).",
    "Un eucalipto (familia Myrtaceae).",
    "Un ave migratoria.",
    "Escaneá el código QR de un árbol y anotá su nombre científico.",
    "Estimá el diámetro del tronco de un árbol (en cm).",
    "Una especie nativa de América del Sur.",
    "Dos especies distintas que pertenezcan a la misma familia.",
]

PREAMBULO = r"""\documentclass[12pt]{article}
\usepackage[spanish]{babel}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage{graphicx}
\usepackage{amssymb}
\usepackage[dvipsnames]{xcolor}
\usepackage{enumitem}
\usepackage{geometry}
\geometry{a4paper, margin=1.8cm}
\definecolor{verde}{HTML}{1E4A38}
\pagestyle{empty}
\begin{document}
"""

def documento(titulo, subtitulo, consignas):
    logo = (f"\\includegraphics[width=4cm]{{{LOGO}}}\\\\[0.4em]\n"
            if os.path.exists(LOGO) else "")
    items = "\n".join(
        "\\item[{\\LARGE$\\square$}] " + c for c in consignas
    )
    return PREAMBULO + rf"""
\begin{{center}}
{logo}{{\color{{verde}}\LARGE\bfseries {titulo}}}\\[0.2em]
{{\large {subtitulo}}}
\end{{center}}
\vspace{{0.6em}}

\noindent Nombre: \rule{{5cm}}{{0.4pt}} \hfill Escuela: \rule{{5cm}}{{0.4pt}} \hfill Fecha: \rule{{2.5cm}}{{0.4pt}}
\vspace{{1em}}

\noindent Recorré el arboretum y marcá cada consigna que logres cumplir. \textbf{{No hace falta tocar ni arrancar nada}}: alcanza con observar.
\vspace{{0.6em}}

\begin{{itemize}}[itemsep=0.9em, leftmargin=2.2em]
{items}
\end{{itemize}}

\vfill
\begin{{center}}\scriptsize Arboretum de Estancia La Constancia · Mar del Plata, Argentina\end{{center}}
\end{{document}}
"""

def main():
    with open("busqueda_primaria.tex", "w", encoding="utf-8") as f:
        f.write(documento("Búsqueda del Tesoro", "Nivel Primaria", PRIMARIA))
    with open("busqueda_secundaria.tex", "w", encoding="utf-8") as f:
        f.write(documento("Búsqueda del Tesoro", "Nivel Secundaria", SECUNDARIA))
    print("generar_busqueda.py: generados busqueda_primaria.tex y busqueda_secundaria.tex")

if __name__ == "__main__":
    main()
