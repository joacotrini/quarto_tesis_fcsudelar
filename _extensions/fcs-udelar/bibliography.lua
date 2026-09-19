-- Coloca la bibliografía en el lugar del div `#refs` (la convención de los libros
-- Quarto: `::: {#refs}` / `:::` dentro del capítulo de referencias).
--
-- La pauta FCS exige las Referencias antes de los Anexos, pero Quarto emite la
-- llamada a `#bibliography()` después de todo el cuerpo (anexos incluidos). El
-- partial biblio.typ de esta extensión queda vacío para suprimir esa emisión
-- automática, y este filtro escribe la llamada donde está el div.
--
-- Justo después de la bibliografía se apaga la numeración de página. Tiene que
-- ser ahí y no al inicio de los anexos: Quarto adelanta el heading del capítulo
-- siguiente al comienzo de su propia página, antes de cualquier contenido que se
-- escriba al inicio de ese .qmd.

local DEFAULT_CSL = "_extensions/fcs-udelar/apa.csl"

local function typst_string(s)
  return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
end

local function bibliography_files(meta)
  local files = {}
  local bib = meta.bibliography
  if not bib then return files end
  if pandoc.utils.type(bib) == "List" then
    for _, item in ipairs(bib) do
      files[#files + 1] = pandoc.utils.stringify(item)
    end
  else
    files[1] = pandoc.utils.stringify(bib)
  end
  return files
end

local function references_block(meta)
  local lines = {
    -- Espacio simple para la bibliografía; los anexos lo heredan.
    "#set par(justify: true, leading: 0.65em, spacing: 0.65em)",
  }
  local files = bibliography_files(meta)
  if #files > 0 then
    local quoted = {}
    for i, f in ipairs(files) do quoted[i] = typst_string(f) end
    local csl = meta.csl and pandoc.utils.stringify(meta.csl) or DEFAULT_CSL
    lines[#lines + 1] = string.format("#bibliography((%s), style: %s, title: none)",
      table.concat(quoted, ", "), typst_string(csl))
  end
  lines[#lines + 1] = "#fcs-numerar-paginas.update(false)"
  return pandoc.RawBlock("typst", table.concat(lines, "\n"))
end

function Pandoc(doc)
  local found = false
  local blocks = doc.blocks:walk({
    Div = function(div)
      if div.identifier == "refs" then
        found = true
        return references_block(doc.meta)
      end
    end,
  })

  -- Sin div `#refs`, la bibliografía iría al final del documento, como hace
  -- Quarto por defecto, en lugar de perderse en silencio.
  if not found then
    quarto.log.warning("fcs-udelar: no hay un div `#refs` en el documento; la bibliografía se agrega al final.")
    blocks:insert(references_block(doc.meta))
  end

  return pandoc.Pandoc(blocks, doc.meta)
end
