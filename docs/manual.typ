#import "@preview/tidy:0.4.3"
#import "/src/lib.typ": *
#import "tidy-style.typ"

#let package = toml("/typst.toml").package

#show: quire.with(
  title: [quire],
  subtitle: [A classical template for books, reports and articles],
  authors: package.authors.map(author => author.split(" <").first()),
  version: [v#package.version],
  lang: "en",
  top-level: "chapter",
  output: "digital",
  kicker: [Package manual],
  info: (([Repository], link(package.repository, package.repository.trim("https://", at: start))),),
  license: [The package is distributed under the #package.license license.],
  abstract: [
    _quire_ typesets books, reports and articles in a classical style: EB Garamond text with small caps, quiet
    sans-serif labels, thin golden rules and generous margins. It adapts to print (recto openings, wider inner
    margins, link footnotes) and to screens, to documents divided in parts, chapters or just sections, and to
    English, Spanish and Catalan. This manual is itself typeset with it.
  ],
  keywords: ("Typst", "template", "typography", "book", "article"),
)

#let pkg = "@preview/quire:" + package.version

// Render the reference of a module with the quire style for tidy.
#let reference(path, ..args) = {
  let docs = tidy.parse-module(read(path), label-prefix: path.split("/").last().trim(".typ", at: end) + "-")
  tidy.show-module(
    docs,
    style: tidy-style,
    show-module-name: false,
    show-outline: false,
    omit-private-definitions: true,
    omit-private-parameters: true,
    sort-functions: none,
    ..args,
  )
}

= Introduction

_quire_ grew out of a bachelor's thesis and keeps its appearance while dropping everything specific to it. A
_quire_ is a gathering of folded sheets, the unit books are sewn from; the template is meant for documents that may
end up bound, but read just as well on screen.

Its main features are:

- A classical style, set in EB Garamond, Fira Sans, Garamond-Math and JuliaMono, which can be changed through a
  small interface for fonts and colors (@customization).
- Three document structures, chosen with `top-level`: divided in parts, in chapters, or only in sections
  (@structure).
- Print and digital output (@output).
- Title page, dedication and colophon, acknowledgments, abstracts in several languages and table of contents for
  books and reports, or a title block for articles (@front-matter).
- Theorem-like environments, code listings with file names, appendices and localized names in English, Spanish and
  Catalan (@elements).

= Getting started <getting-started>

== Fonts

The default style uses the following fonts, which are *not* bundled with the package and must be installed on your
system (or uploaded to your project in the web app):

#table(
  columns: (auto, 1fr),
  stroke: none,
  table.hline(stroke: 0.6pt),
  table.header([*Family*], [*Usage*]),
  table.hline(stroke: 0.4pt + default-colors.rule),
  [EB Garamond 12, EB Garamond 08], [Body text and footnotes (the Georg Duffner and Octavio Pardo release).],
  [Fira Sans], [Labels, running heads, numbers.],
  [Garamond-Math], [Mathematics.],
  [JuliaMono], [Raw text and code listings.],
  table.hline(stroke: 0.6pt),
)

Any of them can be replaced with the `fonts` option (@customization).

== Creating a document

Start a new project from the template with

```sh
typst init @preview/quire
```

or import the package in an existing document and apply the template function with a show rule:

#raw(
  lang: "typ",
  block: true,
  "#import \""
    + pkg
    + "\": *\n\n#show: quire.with(\n  title: [On Bookbinding],\n  authors: \"Jane Doe\",\n  lang: \"en\",\n)\n\n= Introduction\n…",
)

= Document structure <structure>

The `top-level` option gives the role of level-1 headings, and with it the role of every heading level. Roles drive
how headings look, where pages break, what the running heads show and how elements are numbered.

#table(
  columns: (auto, 1fr, 1fr, 1fr),
  stroke: none,
  table.hline(stroke: 0.6pt),
  table.header([*`top-level`*], [*`=`*], [*`==`*], [*`===`*]),
  table.hline(stroke: 0.4pt + default-colors.rule),
  [`"part"`], [Part], [Chapter], [Section],
  [`"chapter"`], [Chapter], [Section], [Subsection],
  [`"section"`], [Section], [Subsection], [—],
  table.hline(stroke: 0.6pt),
)

- *Parts* open on a page of their own, numbered with Roman numerals. Chapters are numbered continuously across
  parts.
- *Chapters* open on a new page with a large number. The `chapter` function gives them an opening page of their own,
  with an optional epigraph.
- *Sections* show the section sign and number above the title; *subsections* and deeper headings show the number
  inline.

Figures, tables, listings, labeled equations and theorem-like environments are numbered within sections, e.g.
Figure 2.3.1 is the first figure in section 3 of chapter 2. Only labeled equations are numbered, since only those
can be referenced.

With `top-level: "section"` the document is an article: it gets a title block instead of a title page, its abstracts
are shown below it, and the table of contents is hidden unless requested.

= Output <output>

The `output` option adapts the document to its medium.

/ `"digital"`: Symmetric margins, no blank pages, and colored external links.
/ `"print"`: A wider inner margin for binding; parts, chapters and the main matter start on a recto (an odd page),
  with blank pages inserted as needed and left without running head or folio; external links are not colored, and
  links made with `href` get a footnote with their address.

= Front matter <front-matter>

Books and reports (with `title-page: true`, the default unless `top-level` is `"section"`) start with these pages,
numbered with Roman numerals; each one is omitted when its content is `none`:

+ The *title page*: the `institution` (and `logo`), the `kicker`, `title` and `subtitle`, and a grid with the
  authors and the `info` rows, with the `date` and `version` at the bottom.
+ The *dedication page*: the `dedication`, and the `colophon` at the bottom. By default, the colophon gathers the
  title, a copyright line, the `license`, the fonts and the Typst version, the version and the date.
+ The *acknowledgments*.
+ The *abstracts*: one page per abstract. Pass an array of dictionaries to write abstracts in several languages,
  each with its own keywords.
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
dates yet (#href("https://github.com/typst/typst/issues/2840")[typst/typst\#2840]). Until it does, pass the date as
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
overridden, `serif-small` follows it. Since EB Garamond has no bold weight, strong emphasis is rendered in small
caps; with a family that has one, set `strong: "bold"`.

All sizes are relative to `font-size` (12pt by default), and the page is set by `paper`. Further adjustments can be
made with set and show rules after the template.

The default fonts and colors are:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,
  for (key, spec) in default-fonts [
    / #raw(key): #spec.font
  ],
  for (key, color) in default-colors [
    / #raw(key): #box(baseline: 0.15em, rect(width: 0.9em, height: 0.9em, fill: color)) #raw(color.to-hex())
  ],
)

= Elements <elements>

== Theorems

Theorem-like environments are built on #href("https://typst.app/universe/package/theorion")[theorion]: `theorem`,
`lemma`, `proposition`, `corollary` and `conjecture` have an italic body; `definition`, `assumption`, `axiom` and
`example` an upright one; `remark`, `note` and `warning` an italic title. They all share one counter.

#theorem(title: [Euclid])[There are infinitely many prime numbers.] <thm:euclid>

#proof(of: [@thm:euclid])[
  Given finitely many primes, one plus their product is divisible by none of them.
]

== Code

Code blocks are styled with #href("https://typst.app/universe/package/codly")[codly]; `code-file` adds a header
with a file name.

#code-file(filename: "hello.py")[
  ```python
  def hello(name: str) -> str:
      return f"Hello, {name}!"  # Greet someone.
  ```
]

== Links and references

`href` makes an external link that survives printing, and `ref-titled` references a heading followed by its title,
as in #ref-titled(<structure>).

== Appendices

`#show: appendix` letters the following chapters (or sections) and names them "Appendix".

== Localization

Names of divisions, the bibliography, the abstract and the like follow the document language: English (`"en"`),
Spanish (`"es"`) and Catalan (`"ca"`), with English as fallback. Set it with the `lang` option.

= Reference <reference>

== The template

#reference("/src/quire.typ")

== Divisions

#reference("/src/headings.typ")

== Theorems

#reference("/src/theorems.typ", show-outline: false)

== Code, links and references

#reference("/src/code.typ")
#reference("/src/links.typ")

== Style and localization

#reference("/src/config.typ")
#reference("/src/i18n.typ")
