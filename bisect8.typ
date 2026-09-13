// Simple numbering for non-book documents
#let equation-numbering = "(1)"
#let callout-numbering = "1"
#let subfloat-numbering(n-super, subfloat-idx) = {
  numbering("1a", n-super, subfloat-idx)
}

// Theorem configuration for theorion
// Simple numbering for non-book documents (no heading inheritance)
#let theorem-inherited-levels = 0

// Theorem numbering format (can be overridden by extensions for appendix support)
// This function returns the numbering pattern to use
#let theorem-numbering(loc) = "1.1"

// Default theorem render function
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  if full-title != "" and full-title != auto and full-title != none {
    strong[#full-title.]
    h(0.5em)
  }
  body
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



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
#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "a4",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
  columns: 1,
)

#show: doc => conf(
  title: [Título del trabajo],
  autor: [Nombre y Apellido],
  tutor: [Nombre y Apellido, título profesional],
  departamento: [xxx],
  licenciatura: [xxx],
  lugar: [Montevideo],
  anio: [2026],
  lang: "es",
  fontsize: 12pt,
  papersize: "a4",
  doc,
)
// Reset Quarto's custom figure counters at each chapter (level-1 heading).
// Orange-book only resets kind:image and kind:table, but Quarto uses custom kinds.
// This list is generated dynamically from crossref.categories.
#show heading.where(level: 1): it => {
  counter(figure.where(kind: "quarto-float-fig")).update(0)
  counter(figure.where(kind: "quarto-float-tbl")).update(0)
  counter(figure.where(kind: "quarto-float-lst")).update(0)
  counter(figure.where(kind: "quarto-callout-Note")).update(0)
  counter(figure.where(kind: "quarto-callout-Warning")).update(0)
  counter(figure.where(kind: "quarto-callout-Caution")).update(0)
  counter(figure.where(kind: "quarto-callout-Tip")).update(0)
  counter(figure.where(kind: "quarto-callout-Important")).update(0)
  counter(math.equation).update(0)
  it
}

#heading(level: 1, numbering: none)[Dedicatoria]
A quienes me acompañaron en este proceso.

#heading(level: 1, numbering: none)[Agradecimientos]
Agradezco a mi tutor/a por la orientación brindada a lo largo de este trabajo, a mi familia por el apoyo constante, y a la Facultad de Ciencias Sociales por la formación recibida.

#heading(level: 1, numbering: none)[Resumen]
Este trabajo aborda un problema sociológico específico a partir de una revisión bibliográfica y la aplicación de conocimientos teóricos y metodológicos adquiridos a lo largo de la carrera. El objetivo general consiste en analizar las dimensiones centrales del problema planteado, identificando sus antecedentes, su relevancia y las condiciones en que se manifiesta.

El abordaje utilizado combina una estrategia cualitativa con el análisis documental de fuentes primarias y secundarias, atendiendo a las consideraciones éticas correspondientes. Las principales conclusiones muestran que el fenómeno estudiado presenta múltiples dimensiones que requieren un abordaje integral, y se proponen líneas de indagación para futuras investigaciones.

#heading(level: 1, numbering: none)[Tabla de contenido]
#outline(title: none, depth: 3)
#heading(level: 1, numbering: none)[Índice de figuras y tablas]
#outline(title: [Índice de figuras], target: figure.where(kind: "quarto-float-fig"))
#outline(title: [Índice de tablas], target: figure.where(kind: "quarto-float-tbl"))
= Resultados y discusión
== Presentación de resultados
Los datos relevados muestran una tendencia sostenida a lo largo del período analizado, tal como se observa en la #ref(<fig-tendencia>, supplement: [Figura]).

#figure([
#box(image("images/figura-ejemplo.svg"))
], caption: figure.caption(
position: bottom, 
[
Evolución del fenómeno estudiado, 2023-2025 (datos de ejemplo)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-tendencia>



#bibliography("references.bib", style: "_extensions/fcs-udelar/apa.csl")
