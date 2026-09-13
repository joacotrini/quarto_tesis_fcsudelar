# Monografía de grado FCS-Udelar (Quarto + Typst)

Plantilla Quarto que implementa el instructivo oficial ["Pautas de presentación de
monografías de grado"](devdocs/Pautas-Presentacion-de-monografias-de-grado%20(1).pdf)
(Facultad de Ciencias Sociales, Udelar, marzo 2026, Res. 230). Usa un proyecto tipo
`book` con salida a PDF vía [Typst](https://typst.app), a través de una extensión
Quarto propia (`_extensions/fcs-udelar/`).

## Requisitos

- [Quarto](https://quarto.org) ≥ 1.4 (probado con 1.10.18). Trae Typst embebido, no hace
  falta instalarlo aparte.
- **Fuentes** (opcional pero recomendado): la pauta exige **Tahoma** para la portada y
  **Times New Roman** para el cuerpo del texto. Son fuentes propietarias de Microsoft
  (vienen con Office/Windows/macOS). Si están instaladas en tu máquina, Typst las usa
  automáticamente. Si no, cae en un *fallback* visualmente similar (DejaVu Sans /
  Liberation Serif) — el documento se ve casi igual, pero para la entrega final conviene
  compilar en una máquina con esas fuentes instaladas, o instalarlas manualmente.

## Cómo compilar

```bash
quarto render
```

El PDF final queda en `_book/<título>.pdf`. Para previsualizar mientras se escribe:

```bash
quarto preview
```

## Completar los datos del trabajo

Todos los campos de la portada se completan en `_quarto.yml`:

```yaml
autor: "Nombre y Apellido"
tutor: "Nombre y Apellido, título profesional"
departamento: "xxx"              # el departamento correspondiente
licenciatura: "xxx"              # Trabajo Social | Sociología | Ciencia Política | Desarrollo
lugar: "Montevideo"
anio: "2026"                      # obligatorio según la pauta
# referente-taller2: "Nombre y Apellido"   # solo Licenciatura en Desarrollo
```

El título del trabajo se completa en `book: title:`, también en `_quarto.yml`.

**Importante:** la pauta pide que el título se escriba "en minúscula, con excepción de la
letra inicial de la primera palabra y la de los nombres propios" — esto no se puede
automatizar de forma confiable (por los nombres propios), así que hay que escribirlo así
directamente en `book: title:`.

## Estructura de capítulos

Cada archivo `.qmd` numerado es un capítulo, listado en `_quarto.yml` bajo
`book: chapters:`. Se puede reordenar, agregar o quitar libremente, agregando/quitando
el archivo correspondiente de esa lista.

- `index.qmd`: Dedicatoria, Agradecimientos, Resumen, Tabla de contenido e Índice de
  figuras/tablas (las páginas preliminares).
- `01-introduccion.qmd` … `05-conclusiones.qmd`: cuerpo del trabajo.
- `06-referencias.qmd`: llama a `#bibliography()` a mano — **no mover** el contenido de
  este archivo después de los anexos (ver sección siguiente).
- `07-anexos.qmd`: anexos, sin numeración de página.

### Cómo quitar Dedicatoria o Agradecimientos

Son opcionales según la pauta. Para quitarlas, borrar el bloque correspondiente (heading
+ texto) directamente en `index.qmd`.

### Por qué la bibliografía y los anexos están "acoplados"

Typst exige que `#bibliography()` se llame una sola vez, y Quarto por defecto la inserta
automáticamente *al final de todo el documento* — es decir, después de los anexos, algo
que la pauta prohíbe explícitamente ("antes de los anexos"). Para evitarlo, la extensión
suprime esa inserción automática (ver `_extensions/fcs-udelar/biblio.typ`, queda vacío a
propósito) y la llamada real a `#bibliography()` está escrita a mano al final de
`06-referencias.qmd`. En ese mismo lugar se apaga la numeración de página
(`#fcs-numerar-paginas.update(false)`) para que los anexos queden sin numerar, tal como
pide la pauta. **Si agregás contenido entre referencias y anexos, agregalo antes de esa
línea de `#fcs-numerar-paginas.update(false)`, no después.**

## Figuras, tablas y citas

- Figuras: sintaxis estándar de Quarto (`![caption](ruta){#fig-id}`), referenciadas con
  `@fig-id`.
- Tablas: tablas markdown con `: Caption {#tbl-id}`, referenciadas con `@tbl-id`.
- Citas: `[@clave]` o `[@clave, p. 20]`, con las entradas correspondientes en
  `references.bib`. El estilo es APA 7 (`_extensions/fcs-udelar/apa.csl`), el único
  recomendado por la pauta (la FCS no exige una norma institucional específica).

## Logos

Los logos oficiales combinados FCS+Udelar (descargados de la página de identidad
gráfica de la facultad) están en `_extensions/fcs-udelar/logos/` (usado en la portada) y
en `devdocs/` (PNG, PDF vectorial y manual de identidad, como referencia si hace falta
regenerar algo con más calidad o revisar los lineamientos de marca).

## Qué automatiza la plantilla y qué no

Automatizado: márgenes, tipografía y tamaños de fuente, interlineado 1.5 con las
excepciones a espacio simple (citas en bloque, bibliografía, índices, anexos),
numeración de página (arranca en 1 después de la portada, se apaga en anexos), salto de
página en cada capítulo, tabla de contenido e índice de figuras/tablas.

Responsabilidad de quien escribe (no se puede automatizar de forma confiable):

- Título y encabezados en minúscula tipo oración, salvo nombres propios.
- Uso de cursiva solo para palabras que no están en español.
- Elegir fuentes primarias para las citas cuando sea posible.

## Supuestos adoptados ante ambigüedades de la pauta

- El título de la portada se centra (la pauta lo dice explícitamente); autor/a, tutor/a,
  lugar y año se alinean a la izquierda, siguiendo el mockup visual de la página 3 del
  instructivo (el texto normativo no especifica alineación para estos campos).
- Los encabezados de capítulo no llevan numeración automática (1., 1.1, ...) por
  defecto, ya que la pauta no lo exige. Se puede activar con `section-numbering` en
  `_quarto.yml` si se prefiere.
