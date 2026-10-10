// The preview image of the README: a strip with pages of the compiled examples.
#set page(width: auto, height: auto, margin: 12pt, fill: white)
#set text(font: "Fira Sans", size: 9pt, fill: luma(40%))

#let preview(path, page, caption) = stack(
  spacing: 8pt,
  box(stroke: 0.5pt + luma(78%), image(path, page: page, width: 150pt)),
  align(center, caption),
)

#stack(
  dir: ltr,
  spacing: 14pt,
  preview("/examples/book.pdf", 1, [Title page]),
  preview("/examples/book.pdf", 15, [Chapter opening]),
  preview("/examples/book.pdf", 16, [Body]),
  preview("/examples/article.pdf", 1, [Article]),
)
