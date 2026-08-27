-- Typst-only: render each `.cv-entry` (a .columns div with two .column children)
-- as a two-column #grid so the date sits beside the entry, as it does in HTML.
-- HTML output is untouched (it uses the .columns flex layout + custom.scss).

if not quarto.doc.is_format("typst") then
  return {}
end

local function to_typst(blocks)
  local s = pandoc.write(pandoc.Pandoc(blocks), "typst")
  return (s:gsub("%s+$", ""))
end

-- Grey, slightly smaller detail line (mirrors .cv-detail in custom.scss).
local function detail_span(span)
  if not span.classes:includes("cv-detail") then return nil end
  local inner = to_typst({ pandoc.Plain(span.content) })
  return pandoc.RawInline("typst",
    "#text(size: 0.92em, fill: luma(90))[" .. inner .. "]")
end

-- Portrait: pin to the top-right of the first page beside the title.
function Image(el)
  if not el.classes:includes("cv-photo") then return nil end
  return pandoc.RawInline("typst",
    "#place(top + right, dy: -7.6em, "
    .. "box(clip: true, radius: 50%, image(\"" .. el.src .. "\", width: 3cm)))")
end

function Div(el)
  if el.classes:includes("cv-contact") then
    return pandoc.RawBlock("typst",
      "#block(width: 78%, text(size: 0.95em)[" .. to_typst(el.content) .. "])\n#v(0.6em)")
  end
  if not el.classes:includes("cv-entry") then return nil end
  local cols = {}
  for _, b in ipairs(el.content) do
    if b.t == "Div" and b.classes:includes("column") then cols[#cols + 1] = b end
  end
  if #cols ~= 2 then return nil end
  local body = cols[2]:walk({ Span = detail_span })
  local when = to_typst(cols[1].content)
  local what = to_typst(body.content)
  return pandoc.RawBlock("typst",
    "#grid(columns: (7.5em, 1fr), column-gutter: 0.8em, row-gutter: 0pt,\n"
    .. "  text(fill: luma(90))[" .. when .. "],\n"
    .. "  [" .. what .. "])\n#v(0.45em)")
end
