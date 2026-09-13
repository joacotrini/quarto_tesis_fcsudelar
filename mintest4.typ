// Extensión Typst para monografías de grado FCS-Udelar.
// Implementa "Pautas de presentación de monografías de grado" (FCS, marzo 2026).

// Estado global: controla si el número de página se dibuja o no.
// Se apaga a mano en 07-anexos.qmd (la pauta indica que los anexos no se numeran).
#let fcs-numerar-paginas = state("fcs-numerar-paginas", true)

#let conf(
  title: none,
  autor: none,
  tutor: none,
  referente-taller2: none,
  departamento: "xxx",
  licenciatura: "xxx",
  lugar: "Montevideo",
  anio: none,
  lang: "es",
  region: "UY",
  fontsize: 12pt,
  linestretch: 1.5,
  papersize: "a4",
  margin: (left: 3cm, top: 3cm, right: 2.5cm, bottom: 2.5cm),
  section-numbering: none,
  doc,
) = {
  set document(title: title) if title != none

  // ---------------------------------------------------------------------
  // Portada (1.1): página propia, sin numeración, fuente Tahoma.
  // ---------------------------------------------------------------------
  {
    set page(
      paper: papersize,
      margin: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
      numbering: none,
    )
    set text(font: ("Tahoma", "Verdana", "DejaVu Sans"), lang: lang, region: region, size: 11pt)
    set par(justify: false)

    image("_extensions/fcs-udelar/logos/logo-fcs-udelar.png", width: 75%)
    v(2.5em)

    align(center)[
      Departamento de #departamento, Facultad de Ciencias Sociales, Universidad de la República
    ]
    v(1.5em)
    align(center, text(size: 16pt)[Monografía Licenciatura en #licenciatura])
    v(4em)
    align(center, text(size: 22pt)[#title])

    v(1fr)

    text(size: 16pt)[#autor]
    linebreak()
    text(size: 16pt)[#tutor]
    if referente-taller2 != none {
      linebreak()
      text(size: 16pt)[Referente Taller II: #referente-taller2]
    }

    v(3em)

    text(size: 11pt)[#lugar]
    linebreak()
    text(size: 11pt)[#anio]
  }
  pagebreak()

  // ---------------------------------------------------------------------
  // Cuerpo del texto (sección II del instructivo).
  // ---------------------------------------------------------------------
  set page(
    paper: papersize,
    margin: margin,
    numbering: none,
    background: context {
      if fcs-numerar-paginas.get() {
        place(bottom + right, dx: -1.5cm, dy: -1.5cm)[#counter(page).display()]
      }
    },
  )
  counter(page).update(1)

  set text(font: ("Times New Roman", "Liberation Serif"), size: fontsize, lang: lang, region: region)
  set par(
    justify: true,
    leading: linestretch * 0.65em,
    spacing: linestretch * 0.65em + 0.5em,
  )
  set heading(numbering: section-numbering)

  // Cada capítulo (heading nivel 1) arranca en página nueva, con doble
  // espacio antes de que empiece el cuerpo del texto.
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
    v(2em, weak: true)
  }

  // Espacio simple en citas en bloque (excepción explícita del instructivo).
  show quote.where(block: true): set par(leading: 0.65em, spacing: 0.65em)

  // Doble espacio antes/después de intercalar figuras y tablas.
  show figure: it => {
    v(2em, weak: true)
    it
    v(2em, weak: true)
  }

  doc
}

#show: doc => conf(
  title: [T],
  autor: [A],
  tutor: [Tu],
  doc,
)
#show heading.where(level: 1): it => {
  counter(figure.where(kind: "quarto-float-fig")).update(0)
  counter(figure.where(kind: "quarto-float-tbl")).update(0)
  counter(figure.where(kind: "quarto-float-lst")).update(0)
  counter(math.equation).update(0)
  it
}

= Indice de figuras y tablas
#outline(title: [Indice de figuras], target: figure.where(kind: "quarto-float-fig"))
#outline(title: [Indice de tablas], target: figure.where(kind: "quarto-float-tbl"))

= Metodologia
#figure([
#table(columns: 2, [A],[B],)
], caption: figure.caption(position: top, [Tabla ejemplo]), kind: "quarto-float-tbl", supplement: "Tabla")
<tbl-fuentes>

= Resultados
#figure([
#box(image("images/figura-ejemplo.svg"))
], caption: figure.caption(position: bottom, [Mi figura]), kind: "quarto-float-fig", supplement: "Figura")
<fig-tendencia>
