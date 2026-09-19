# Monografía de grado FCS-Udelar (Quarto + Typst)

Plantilla Quarto que implementa el instructivo oficial ["Pautas de presentación de monografías de grado"](https://cienciassociales.edu.uy/estudiantes/pautas-de-presentacion-de-monografias-de-grado/) (res. de Consejo 230 del 16 de marzo de 2026) de la Facultad de Ciencias Sociales de la Universidad de la República, Uruguay. Usa un proyecto tipo `book` con salida a PDF vía [Typst](https://typst.app), a través de una extensión Quarto propia (`_extensions/fcs-udelar/`).

## Requisitos

- [Quarto](https://quarto.org) ≥ 1.4 (probado con 1.10.18). Trae Typst embebido, no hace falta instalarlo aparte.
- **Fuentes** (opcional pero recomendado): la pauta exige **Tahoma** para la portada y **Times New Roman** para el cuerpo del texto. Son fuentes propietarias de Microsoft (vienen con Office/Windows/macOS). Si están instaladas en tu máquina, Typst las usa automáticamente. Si no, cae en un *fallback* visualmente similar (DejaVu Sans / Liberation Serif); el documento se ve casi igual, pero para la entrega final conviene compilar en una máquina con esas fuentes instaladas, o instalarlas manualmente.

## Cómo compilar

``` bash
quarto render
```

El PDF final queda en `_book/<título>.pdf`. Para previsualizar mientras se escribe:

``` bash
quarto preview
```

## Completar los datos del trabajo

Todos los campos de la portada se completan en `_quarto.yml`:

``` yaml
autor: "Nombre y Apellido"
tutor: "Nombre y Apellido, título profesional"
departamento: "Departamento de xxx"   # nombre completo de la unidad (Departamento de ..., Instituto de ...)
licenciatura: "xxx"              # Trabajo Social | Sociología | Ciencia Política | Desarrollo
lugar: "Montevideo"
anio: "2026"                      # obligatorio según la pauta
# referente-taller2: "Nombre y Apellido"   # solo Licenciatura en Desarrollo
```

El título del trabajo se completa en `book: title:`, también en `_quarto.yml`. Notar que para el caso de Desarrollo hay que descomentar la última línea del código anterior.

**Importante:** la pauta pide que el título se escriba "en minúscula, con excepción de la letra inicial de la primera palabra y la de los nombres propios". Esto no se puede automatizar de forma confiable (por los nombres propios), así que hay que escribirlo así directamente en `book: title: (ver _quarto.yml)`.

## Estructura de capítulos

Cada archivo `.qmd` numerado es un capítulo, listado en `_quarto.yml` bajo `book: chapters:`. Se puede reordenar, agregar o quitar libremente, agregando/quitando el archivo correspondiente de esa lista.

- `index.qmd`: Dedicatoria, Agradecimientos, Resumen, Tabla de contenido e Índice de figuras/tablas (las páginas preliminares).
- `01-introduccion.qmd` … `05-conclusiones.qmd`: cuerpo del trabajo.
- `06-referencias.qmd`: el heading y un div `::: {#refs}` vacío, donde la extensión coloca la bibliografía (ver sección siguiente). **Tiene que quedar antes de los anexos.**
- `07-anexos.qmd`: anexos, sin numeración de página.

### Secciones opcionales y cómo quitarlas

La pauta marca como opcionales o condicionales las partes de la tabla. Cada una se probó quitándola de la forma indicada: el PDF se genera sin errores, la numeración de página y la tabla de contenido se ajustan solas, y el resto del documento no cambia.

| Parte (pauta) | Cómo quitarla |
|---|---|
| Dedicatoria (1.2) y Agradecimientos (1.3) | Borrar el bloque correspondiente (`# heading` + texto) en `index.qmd`. Se puede quitar una, otra o ambas. |
| Índice de figuras y tablas (1.6, "si corresponde") | Si el trabajo no tiene figuras o no tiene tablas, el índice de ese tipo se omite solo. Si no tiene ninguna de las dos, borrar el bloque `# Índice de figuras y tablas` de `index.qmd` (si se deja, queda una página con solo el título). |
| Metodología ("cuando corresponda") | Quitar `03-metodologia.qmd` de `book: chapters:` en `_quarto.yml`. Ojo: si allí estaba la única tabla, desaparece de la tabla de contenido y del índice de tablas, y las referencias en el texto a `@tbl-...` que queden en otros capítulos van a fallar. |
| Contexto y demás subsecciones ("si el trabajo lo requiere", "podrán incluir") | Borrar el `## heading` y su texto. También se pueden quitar todos los subcapítulos: la tabla de contenido queda solo con los capítulos. |
| Material complementario / anexos (2.6, "optativo") | Quitar `07-anexos.qmd` de `book: chapters:`. La numeración de página termina en las referencias, como antes. |
| Referente Taller II (solo Licenciatura en Desarrollo) | Descomentar `referente-taller2` en `_quarto.yml` (ver arriba). Si queda comentado, la portada no lo muestra. |

Al quitar figuras o tablas del texto, borrar también las referencias `@fig-...` o `@tbl-...` que las citan.

### Cómo se ubica la bibliografía respecto de los anexos

Typst exige que `#bibliography()` se llame una sola vez, y Quarto por defecto la inserta automáticamente *al final de todo el documento* (es decir, después de los anexos, algo que la pauta prohíbe explícitamente; cf. "antes de los anexos" en el pdf citado más arriba). Para evitarlo, la extensión suprime esa inserción automática (ver `_extensions/fcs-udelar/biblio.typ`, queda vacío a propósito) y un filtro Lua (`_extensions/fcs-udelar/bibliography.lua`) escribe la llamada real a `#bibliography()` en el lugar del div `::: {#refs}` de `06-referencias.qmd`, la misma convención que usan los libros de Quarto. En ese mismo lugar el filtro apaga la numeración de página (`#fcs-numerar-paginas.update(false)`) para que los anexos queden sin numerar, tal como pide la pauta. **Si agregás contenido entre referencias y anexos, agregalo antes del div `#refs`, no después.**

Si el div `#refs` falta, el filtro avisa con un warning y agrega la bibliografía al final del documento (después de los anexos y con los anexos numerados).

## Figuras, tablas y citas

- Figuras: sintaxis estándar de Quarto (`![caption](ruta){#fig-id}`), referenciadas con `@fig-id`.
- Tablas: tablas markdown con `: Caption {#tbl-id}`, referenciadas con `@tbl-id`.
- Citas: `[@clave]` o `[@clave, p. 20]`, con las entradas correspondientes en `references.bib`. El estilo es APA 7 (`_extensions/fcs-udelar/apa.csl`), el único recomendado por la pauta (la FCS no exige una norma institucional específica, pero nunca he visto que se usara otra).

## Logos

Los logos oficiales combinados FCS+Udelar (descargados de la [página de identidad gráfica de la facultad](https://cienciassociales.edu.uy/institucional/unidad-de-comunicacion-y-publicaciones/identidad-grafica/)) están en `_extensions/fcs-udelar/logos/` (usado en la portada).

## Qué automatiza la plantilla y qué no

Automatizado: márgenes, tipografía y tamaños de fuente, interlineado 1.5 con las excepciones a espacio simple (citas en bloque, bibliografía, índices, anexos), numeración de página (arranca en 1 después de la portada, se apaga en anexos), salto de página en cada capítulo, tabla de contenido e índice de figuras/tablas.

Responsabilidad de quien escribe (no se puede automatizar de forma confiable):

- Título y encabezados en minúscula tipo oración, salvo nombres propios.
- Uso de cursiva solo para palabras que no están en español.
- Elegir fuentes primarias para las citas cuando sea posible.

## Supuestos adoptados ante ambigüedades de la pauta

- El título de la portada se centra (la pauta lo dice explícitamente); autor/a, tutor/a, lugar y año se alinean a la izquierda, siguiendo el mockup visual de la página 3 del instructivo (el texto normativo no especifica alineación para estos campos).
- Los encabezados de capítulo no llevan numeración automática (1., 1.1, ...) por defecto, ya que la pauta no lo exige. Se puede activar con `section-numbering` en `_quarto.yml` si se prefiere.