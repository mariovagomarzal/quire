/// A tidy style matching quire: signatures in a tinted block set in the monospace font, parameter names in the link
/// color, and types as quiet labels.
#import "@preview/tidy:0.4.3": utilities
#import "/src/lib.typ": default-colors, default-fonts

#let _colors = default-colors
#let _tint = _colors.rule.lighten(88%)


#let show-outline(module-doc, style-args: (:)) = {
  let prefix = module-doc.label-prefix
  let entry(name) = if style-args.enable-cross-references { link(label(prefix + name), raw(name)) } else {
    raw(name)
  }
  let names = module-doc.functions.map(fn => fn.name + "()") + module-doc.variables.map(var => var.name)
  if names.len() > 0 {
    block(names.map(entry).join(h(0.6em) + text(fill: _colors.rule)[·] + h(0.6em)))
  }
}

#let show-type(type, style-args: (:)) = box(
  inset: (x: 0.25em),
  outset: (y: 0.2em),
  stroke: 0.4pt + _colors.rule,
  radius: 1pt,
  text(fill: _colors.muted, raw(type, lang: none)),
)

#let show-parameter-list(fn, style-args) = block(fill: _tint, width: 100%, inset: (x: 0.8em, y: 0.8em), {
  set par(justify: false, first-line-indent: 0pt, hanging-indent: 0pt)
  set text(size: 0.95em)
  text(fill: _colors.link, raw(fn.name, lang: none))
  raw("(", lang: none)
  let args = fn.args.pairs().filter(((name, _)) => not (style-args.omit-private-parameters and name.starts-with("_")))
  let inline = args.len() < 4
  let items = args.map(((name, info)) => {
    let shown = raw(name, lang: none)
    if style-args.enable-cross-references and info.at("description", default: "") != "" {
      shown = link(label(style-args.label-prefix + fn.name + "." + name.trim(".")), shown)
    }
    box(shown + if "types" in info { raw(": ", lang: none) + info.types.map(show-type).join(" ") })
  })
  if inline { items.join(raw(", ", lang: none)) } else {
    linebreak()
    items.map(it => h(1.5em) + it).join(raw(",", lang: none) + linebreak())
    linebreak()
  }
  raw(")", lang: none)
  if fn.return-types != none {
    h(0.4em)
    raw("->", lang: none)
    h(0.4em)
    fn.return-types.map(show-type).join(" ")
  }
})

#let show-parameter-block(name, types, content, style-args, show-default: false, default: none, function-name: none) = {
  block(
    breakable: style-args.break-param-descriptions,
    above: 1.2em,
    inset: (left: 1em),
    stroke: (left: 0.6pt + _colors.rule),
    {
      set par(first-line-indent: 0pt)
      let shown = text(fill: _colors.link, raw(name, lang: none))
      if function-name != none and style-args.enable-cross-references [#shown#label(
          function-name + "." + name.trim("."),
        )] else { shown }
      h(0.6em)
      types.map(show-type).join(h(0.3em))
      if show-default {
        h(0.6em)
        text(fill: _colors.muted, raw("= " + default, lang: "typc"))
      }
      parbreak()
      content
    },
  )
}

#let show-function(fn, style-args) = {
  set par(first-line-indent: 0pt)
  let signature = block(breakable: false, above: 2.5em, (style-args.style.show-parameter-list)(fn, style-args))
  if style-args.enable-cross-references [#signature#label(style-args.label-prefix + fn.name + "()")] else {
    signature
  }
  utilities.eval-docstring(fn.description, style-args)
  for (name, info) in fn.args {
    if style-args.omit-private-parameters and name.starts-with("_") { continue }
    let description = info.at("description", default: "")
    if description == "" and style-args.omit-empty-param-descriptions { continue }
    (style-args.style.show-parameter-block)(
      name,
      info.at("types", default: ()),
      utilities.eval-docstring(description, style-args),
      style-args,
      show-default: "default" in info,
      default: info.at("default", default: none),
      function-name: style-args.label-prefix + fn.name,
    )
  }
}

#let show-variable(var, style-args) = {
  set par(first-line-indent: 0pt)
  let signature = block(breakable: false, above: 2.5em, fill: _tint, width: 100%, inset: 0.8em, {
    text(fill: _colors.link, raw(var.name, lang: none))
    if "type" in var { h(0.6em) + show-type(var.type) }
  })
  if style-args.enable-cross-references [#signature#label(style-args.label-prefix + var.name)] else { signature }
  utilities.eval-docstring(var.description, style-args)
}

#let show-reference(label, name, style-args: none) = link(label, raw(name, lang: none))

#let show-example(..args) = none
