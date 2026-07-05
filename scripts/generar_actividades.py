"""
generar_actividades.py
Genera material didáctico para las visitas, alineado con los cronogramas:
  - mision_botanica.tex      (Secundaria: observar y clasificar 5 plantas)
  - detectives_hojas.tex     (Primaria: observar una parte de un árbol)
  - aves_grupos.tex          (Secundaria: checklist de aves por grupo ecológico)

Uso:   python scripts/generar_actividades.py
Salida: los tres .tex (compilar con pdflatex).
"""
import os, openpyxl

ARCHIVO = "data/Arboretum_Master.xlsx"
LOGO = "fotos/logo_lc.jpg"

def has(v): return v is not None and str(v).strip() not in ("", "-", "...", "None")

def preamble(landscape=False):
    geo = "a4paper, landscape, margin=1.5cm" if landscape else "a4paper, margin=1.8cm"
    return (r"""\documentclass[12pt]{article}
\usepackage[spanish]{babel}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage{graphicx}
\usepackage{amssymb}
\usepackage{array}
\usepackage{multicol}
\usepackage[dvipsnames]{xcolor}
\usepackage{geometry}
\geometry{""" + geo + r"""}
\definecolor{verde}{HTML}{1E4A38}
\pagestyle{empty}
\begin{document}
""")

def encabezado(titulo, subtitulo):
    logo = (f"\\includegraphics[width=4cm]{{{LOGO}}}\\\\[0.3em]\n"
            if os.path.exists(LOGO) else "")
    return (r"\begin{center}" + "\n" + logo +
            r"{\color{verde}\LARGE\bfseries " + titulo + r"}\\[0.15em]" + "\n" +
            r"{\large " + subtitulo + r"}" + "\n" + r"\end{center}" + "\n\\vspace{0.4em}\n")

DATOS = (r"\noindent Nombre: \rule{4.5cm}{0.4pt} \hfill Escuela: \rule{4.5cm}{0.4pt}"
         r" \hfill Fecha: \rule{2.5cm}{0.4pt}" + "\n\\vspace{1em}\n\n")

PIE = (r"\vfill\begin{center}\scriptsize Arboretum de Estancia La Constancia "
       r"$\cdot$ Mar del Plata, Argentina\end{center}" + "\n\\end{document}\n")

# ---------------------------------------------------------------- Misión Botánica
def mision_botanica():
    filas = ""
    for i in range(1, 6):
        filas += (f"{i} & & & & & & \\\\[3.2em]\n\\hline\n")
    tabla = (r"\renewcommand{\arraystretch}{1.2}" + "\n" +
        r"\begin{center}\begin{tabular}{|c|p{3.1cm}|p{3.1cm}|p{3.1cm}|p{3.1cm}|p{3.1cm}|p{3.1cm}|}" + "\n"
        r"\hline" + "\n"
        r"\textbf{N°} & \textbf{Altura aprox.} & \textbf{Forma general} & \textbf{Hoja (forma/tamaño)} & \textbf{Color} & \textbf{Flores / frutos} & \textbf{Corteza} \\" + "\n"
        r"\hline" + "\n" + filas +
        r"\end{tabular}\end{center}" + "\n")
    cuerpo = (encabezado("Misión Botánica", "Nivel Secundaria") + DATOS +
        r"\noindent Elegí al menos \textbf{5 plantas distintas}. Observalas y anotá sus "
        r"características (podés dibujar o juntar alguna parte caída). Después, "
        r"\textbf{agrupalas} según sus similitudes y diferencias." + "\n\\vspace{0.8em}\n\n" +
        tabla + "\n\\vspace{0.8em}\n\n" +
        r"\noindent\textbf{Agrupá las plantas} según lo que tienen en común. ¿Qué criterio usaste?" + "\n\n" +
        r"\noindent Grupo A: \rule{14cm}{0.4pt}\\[1.4em]" + "\n" +
        r"\noindent Grupo B: \rule{14cm}{0.4pt}\\[1.4em]" + "\n" +
        r"\noindent Grupo C: \rule{14cm}{0.4pt}\\[0.6em]" + "\n")
    return preamble(landscape=True) + cuerpo + PIE

# ---------------------------------------------------------------- Detectives de hojas
def detectives():
    box = r"\fbox{\parbox[c][6.5cm][c]{\linewidth}{\centering \textit{(dibujá aquí)}}}"
    cuerpo = (encabezado("Detectives de la Naturaleza", "Nivel Primaria") + DATOS +
        r"\noindent Elegí un árbol y una de sus partes. Observala con todos tus sentidos "
        r"(\textbf{menos el gusto}) y completá." + "\n\\vspace{1em}\n\n" +
        r"\noindent\textbf{¿Qué parte elegiste?}\quad "
        r"$\square$ hoja \quad $\square$ corteza \quad $\square$ rama \quad "
        r"$\square$ flor \quad $\square$ fruto \quad $\square$ semilla" + "\n\n\\vspace{1em}\n" +
        r"\noindent ¿Qué \textbf{forma} tiene? \rule{11cm}{0.4pt}\\[1.4em]" + "\n" +
        r"\noindent ¿De qué \textbf{color} es? \rule{11.3cm}{0.4pt}\\[1.4em]" + "\n" +
        r"\noindent ¿Qué \textbf{textura} tiene (lisa, rugosa, blanda…)? \rule{7cm}{0.4pt}\\[1.4em]" + "\n" +
        r"\noindent ¿A qué \textbf{huele}? \rule{11.5cm}{0.4pt}\\[1.4em]" + "\n" +
        r"\noindent ¿El árbol tiene hojas todo el año o las pierde? \quad "
        r"$\square$ Perenne \quad $\square$ Caduco" + "\n\n\\vspace{0.8em}\n" +
        r"\noindent ¿Cómo se \textbf{llama} el árbol? \rule{9.5cm}{0.4pt}\\[1.2em]" + "\n" +
        r"\noindent \textbf{Dibujá lo que observaste:}\\[0.4em]" + "\n" + box + "\n")
    return preamble(landscape=False) + cuerpo + PIE

# ---------------------------------------------------------------- Aves por grupo
GEN_GRUPO = {
    # rapaces (diurnas y nocturnas)
    "Caracara":"Rapaces","Milvago":"Rapaces","Parabuteo":"Rapaces","Falco":"Rapaces",
    "Elanus":"Rapaces","Rupornis":"Rapaces","Athene":"Rapaces","Tyto":"Rapaces",
    # acuáticas y de cañada
    "Nannopterum":"Aves acuáticas y de cañada","Syrigma":"Aves acuáticas y de cañada",
    "Phimosus":"Aves acuáticas y de cañada","Plegadis":"Aves acuáticas y de cañada",
    "Larus":"Aves acuáticas y de cañada","Vanellus":"Aves acuáticas y de cañada",
    # palomas
    "Columba":"Palomas","Patagioenas":"Palomas","Columbina":"Palomas","Zenaida":"Palomas",
    # picaflores
    "Chlorostilbon":"Picaflores","Leucochloris":"Picaflores",
    # carpinteros
    "Colaptes":"Carpinteros",
    # otras (loros, cucos)
    "Myiopsitta":"Otras","Guira":"Otras",
}
ORDEN = ["Rapaces","Aves acuáticas y de cañada","Palomas","Picaflores",
         "Carpinteros","Otras","Pájaros"]

def aves_grupos():
    wb = openpyxl.load_workbook(ARCHIVO, data_only=True)
    ws = wb["Aves"]; rows = list(ws.iter_rows(values_only=True)); h = rows[0]
    ci = {c: i for i, c in enumerate(h)}
    grupos = {g: [] for g in ORDEN}
    vistos = set()
    for r in rows[1:]:
        e = r[ci["especie"]]; s = r[ci["nombre_cientifico"]]
        if not has(e): continue
        key = (str(e).strip(), str(s).strip() if has(s) else "")
        if key in vistos: continue
        vistos.add(key)
        gen = (str(s).split()[0] if has(s) else "")
        g = GEN_GRUPO.get(gen, "Pájaros")
        grupos[g].append(key)

    def esc(x):
        for a,b in [("&",r"\&"),("%",r"\%"),("#",r"\#"),("_",r"\_")]:
            x=x.replace(a,b)
        return x
    partes = [encabezado("Aves del Arboretum", "Nivel Secundaria — por grupos") + DATOS +
        r"\noindent Marcá las aves que veas (\textbf{V}) o escuches (\textbf{E}). "
        r"Para reconocerlas, fijate en el \textbf{pico}, las \textbf{patas}, las "
        r"\textbf{alas}, el \textbf{vuelo} y el \textbf{canto}." + "\n\\vspace{0.6em}\n\n" +
        r"\begin{multicols}{2}" + "\n"]
    for g in ORDEN:
        if not grupos[g]: continue
        partes.append(r"{\color{verde}\bfseries " + g + r"}\\[0.2em]" + "\n")
        for e, s in sorted(grupos[g]):
            sci = f" — \\textit{{{esc(s)}}}" if s else ""
            partes.append(r"$\square$\,V \ $\square$\,E \ " + esc(e) + sci + r"\\[0.15em]" + "\n")
        partes.append(r"\vspace{0.5em}" + "\n")
    partes.append(r"\end{multicols}" + "\n")
    return preamble(landscape=False) + "".join(partes) + PIE

def main():
    salidas = {
        "mision_botanica.tex": mision_botanica(),
        "detectives_hojas.tex": detectives(),
        "aves_grupos.tex": aves_grupos(),
    }
    for nombre, contenido in salidas.items():
        with open(nombre, "w", encoding="utf-8") as f:
            f.write(contenido)
    print("generar_actividades.py: generados", ", ".join(salidas))

if __name__ == "__main__":
    main()
