// The user manual of quire. It deliberately does not use the template itself: it is a plain reference document that
// only borrows a few accents from it (the palette, the sans-serif labels and the thin rules).
#import "@preview/tidy:0.4.3"
#import "/src/lib.typ": default-colors, default-fonts
#import "tidy-style.typ"

#let package = toml("/typst.toml").package
#let pkg = "@preview/quire:" + package.version

#let accent = default-colors.link
#let rule = default-colors.rule
#let sans = "Fira Sans"

// No date, so that the PDF only changes when its sources do.
#set document(
  title: [quire manual],
  author: package.authors.map(author => author.split(" <").first()),
  date: none,
)
#set page(
  paper: "a4",
  margin: (x: 2.8cm, y: 2.5cm),
  numbering: "1",
  footer: context {
    set text(font: sans, size: 8pt, fill: luma(45%))
    [quire #h(0.4em) v#package.version]
    h(1fr)
    counter(page).display()
  },
)
#set text(font: "Libertinus Serif", size: 11pt, lang: "en")
#set par(justify: true, leading: 0.65em)
#show raw: set text(font: "JuliaMono", size: 0.85em)
#show raw.where(block: true): block.with(fill: luma(97%), inset: 0.8em, radius: 2pt, width: 100%)
#show link: it => if type(it.dest) == str { text(fill: accent, it) } else { it }

#set heading(numbering: "1.1")
#show heading: set text(font: sans, weight: "regular")
#show heading.where(level: 1): it => {
  v(1.5em, weak: true)
  line(length: 100%, stroke: 0.5pt + rule)
  v(0.4em)
  text(size: 17pt, {
    if it.numbering != none { text(fill: luma(55%), counter(heading).display()) + h(0.6em) }
    it.body
  })
  v(0.6em)
}
#show heading.where(level: 2): set text(size: 12.5pt)
#show heading.where(level: 3): set text(size: 11pt)

#show outline.entry.where(level: 1): set text(font: sans)
#show outline.entry.where(level: 1): set block(above: 1em)

// A table with thin horizontal rules only.
#let rules-table(..args) = table(
  stroke: none,
  inset: (x: 0.5em, y: 0.45em),
  ..args.named(),
  table.hline(stroke: 0.6pt),
  ..args.pos(),
  table.hline(stroke: 0.6pt),
)

// Shows a page of a compiled example.
#let page-preview(path, page, caption) = figure(
  box(stroke: 0.4pt + luma(75%), image(path, page: page, width: 100%)),
  caption: caption,
  supplement: none,
  numbering: none,
)

// Renders the reference of a module.
#let reference(path) = tidy.show-module(
  tidy.parse-module(read(path), label-prefix: path.split("/").last().trim(".typ", at: end) + "-"),
  style: tidy-style,
  show-module-name: false,
  show-outline: false,
  omit-private-definitions: true,
  omit-private-parameters: true,
  sort-functions: none,
)

// Title.
#block(below: 2.5em, {
  text(font: sans, size: 9pt, tracking: 0.1em, fill: luma(45%), upper[Typst package · v#package.version])
  v(0.2em)
  text(font: sans, size: 30pt)[quire]
  v(-0.6em)
  text(size: 13pt, style: "italic", fill: luma(35%), package.description)
  v(0.4em)
  text(font: sans, size: 9pt, fill: luma(45%))[
    #package.authors.map(author => author.split(" <").first()).join(", ") · #link(package.repository) · #package.license
  ]
  v(0.8em)
  line(length: 100%, stroke: 0.5pt + rule)
})

#outline(title: none, depth: 2, indent: 1.5em)

= Introduction

_quire_ typesets books, reports and articles in a classical style: EB Garamond text with small caps, quiet
sans-serif labels, thin golden rules and generous margins. It adapts to print and to screens, to documents divided in
parts, chapters or just sections, and to English, Spanish and Catalan. A _quire_ is a gathering of folded sheets, the
unit books are sewn from.

#grid(
  columns: 4,
  column-gutter: 1em,
  page-preview("/examples/book.pdf", 1, [Title page]),
  page-preview("/examples/book.pdf", 15, [Chapter opening]),
  page-preview("/examples/book.pdf", 16, [Body]),
  page-preview("/examples/article.pdf", 1, [Article]),
)

The pages above come from the examples in the repository, `examples/book.typ` and `examples/article.typ`, whose
compiled versions are also available there.

= Getting started

== Fonts

The default style uses the following fonts, which are *not* bundled with the package and must be installed on your
system (or uploaded to your project in the web app). Any of them can be replaced (@customization).

#rules-table(
  columns: (auto, 1fr),
  table.header([*Family*], [*Usage*]),
  table.hline(stroke: 0.4pt + rule),
  [EB Garamond 12, EB Garamond 08],
  [Body text and footnotes.],
  [Fira Sans],
  [Labels, running heads and numbers.],
  [Garamond-Math],
  [Mathematics.],
  [JuliaMono],
  [Raw text and code listings.],
)

== Creating a document

Start a new project from the template with

```sh
typst init @preview/quire
```

or import the package in an existing document and apply the template with a show rule:

#raw(
  lang: "typ",
  block: true,
  "#import \""
    + pkg
    + "\": *\n\n#show: quire.with(\n  title: [On Bookbinding],\n  authors: \"Jane Doe\",\n  lang: \"en\",\n)\n\n= Introduction",
)

= Document structure <structure>

The `top-level` option gives the role of level-1 headings, and with it the role of every heading level. Roles decide
how headings look, where pages break, what the running heads show and how elements are numbered.

#rules-table(
  columns: (auto, 1fr, 1fr, 1fr),
  table.header([`top-level`], [`=`], [`==`], [`===`]),
  table.hline(stroke: 0.4pt + rule),
  [`"part"`],
  [Part],
  [Chapter],
  [Section],
  [`"chapter"`],
  [Chapter],
  [Section],
  [Subsection],
  [`"section"`],
  [Section],
  [Subsection],
  [—],
)

- *Parts* open on a page of their own and are numbered with Roman numerals. Chapters are numbered continuously across
  parts.
- *Chapters* open on a new page, with a label that spells the number out ("Chapter one") above a large numeral. The
  `chapter` function gives them an opening page of their own, with an optional epigraph.
- *Sections* show the section sign and number above the title; *subsections* and deeper headings show the number
  inline.

Figures, tables, listings, labeled equations and theorem-like environments are numbered within sections, e.g.
Figure 2.3.1 is the first figure in section 3 of chapter 2. Only labeled equations are numbered, since only those can
be referenced.

With `top-level: "section"` the document is an article: it gets a title block instead of a title page, its abstracts
are shown below it, and the table of contents is hidden unless requested.

= Output

The `output` option adapts the document to its medium.

/ `"digital"`: Symmetric margins, no blank pages, and colored external links.
/ `"print"`: A wider inner margin for binding; parts, chapters and the main matter start on a recto (an odd page),
  with blank pages inserted as needed and left without running head or folio; external links are not colored, and
  links made with `href` get a footnote with their address.

= Front matter

Books and reports (with `title-page: true`, the default unless `top-level` is `"section"`) start with these pages,
numbered with Roman numerals. Each one is omitted when its content is `none`.

+ The *title page*: the `institution` (and `logo`), the `kicker`, `title` and `subtitle`, a grid with the authors and
  the `info` rows, and the `date` and `version` at the bottom.
+ The *dedication page*: the `dedication`, with the `colophon` at the bottom. By default, the colophon gathers the
  title, a copyright line, the `license`, the fonts and Typst version used, the version and the date.
+ The *acknowledgments*.
+ The *abstracts*, one page each. Pass an array of dictionaries to write abstracts in several languages, each with
  its own keywords.
+ The *table of contents*.

```typ
#show: quire.with(
  title: [Higher Categories],
  authors: (name: "Jane Doe", affiliation: [University of Somewhere]),
  kicker: [Master's thesis · 2026],
  institution: ([University of Somewhere], [Faculty of Mathematics]),
  info: (([Supervisor], [John Smith]), ([Defense], [June 2026])),
  abstract: (
    (lang: "en", body: [...], keywords: ("categories",)),
    (lang: "es", body: [...], keywords: ("categorías",)),
  ),
)
```

Dates given as `datetime` are shown as "month year", with month names always in English: Typst does not localize
dates yet (#link("https://github.com/typst/typst/issues/2840")[typst/typst\#2840]). Until it does, pass the date as
content, e.g. `date: [junio de 2026]`.

= Customization <customization>

The `fonts` and `colors` options override the defaults key by key; everything else is derived from them.

```typ
#show: quire.with(
  fonts: (
    serif: "Libertinus Serif",
    sans: (font: "Inter", scale: 0.85),
    math: "Libertinus Math",
  ),
  colors: (link: rgb("#7a1f3d"), rule: rgb("#9aa5b1")),
  strong: "bold",
)
```

A font is a family name, a fallback list, or a dictionary of `text` arguments with an optional `scale`: a factor
applied to sizes so that a sans-serif or monospace family looks matched with the serif text. When only `serif` is
overridden, `serif-small` follows it. Since EB Garamond has no bold weight, strong emphasis is rendered in small caps;
with a family that has one, set `strong: "bold"`.

All sizes are relative to `font-size` (12pt by default), and the page is set by `paper`. Further adjustments, such as
the citation style, can be made with set and show rules after the template:

```typ
#show: quire.with(...)
#set bibliography(style: "chicago-author-date")
```

The defaults are:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,
  rules-table(
    columns: (auto, 1fr),
    table.header([*Font*], [*Family*]),
    table.hline(stroke: 0.4pt + rule),
    ..default-fonts.pairs().map(((key, spec)) => (raw(key), spec.font)).flatten(),
  ),
  rules-table(
    columns: (auto, 1fr),
    table.header([*Color*], [*Value*]),
    table.hline(stroke: 0.4pt + rule),
    ..default-colors
      .pairs()
      .map(((key, color)) => (
        raw(key),
        box(baseline: 0.15em, rect(width: 0.9em, height: 0.9em, fill: color)) + h(0.4em) + raw(color.to-hex()),
      ))
      .flatten(),
  ),
)

= Elements

/ Theorems: Theorem-like environments are built on #link("https://typst.app/universe/package/theorion")[theorion]:
  `theorem`, `lemma`, `proposition`, `corollary` and `conjecture` have an italic body; `definition`, `assumption`,
  `axiom` and `example` an upright one; `remark`, `note` and `warning` an italic title. They all share one counter.
  `proof` ends with a QED symbol and can name what it proves with `of`.
/ Code: Code blocks are styled with #link("https://typst.app/universe/package/codly")[codly]; `code-file` adds a
  header with a file name.
/ Links: `href` makes an external link that survives printing; `ref-titled` references a heading followed by its
  title, e.g. "Chapter 2 (Preliminaries)".
/ Appendices: `#show: appendix` letters the following chapters (or sections) and names them "Appendix".

== Localization

Names of divisions, the bibliography, the abstract and the like follow the text language at the place where they are
shown, as Typst's own names do: English (`"en"`), Spanish (`"es"`) and Catalan (`"ca"`), with English as fallback.
Set the document language with the `lang` option; a block with `#set text(lang: ...)` switches theorem names,
references and the like inside it.

#pagebreak()
= Reference

== The template
#reference("/src/quire.typ")

== Divisions
#reference("/src/headings.typ")

== Theorems
#reference("/src/theorems.typ")

== Code, links and references
#reference("/src/code.typ")
#reference("/src/links.typ")

== Style and localization
#reference("/src/config.typ")
#reference("/src/i18n.typ")
