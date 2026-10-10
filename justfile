set unstable

# Directory where the package is exposed as `@preview/quire` for local compilation.
packages := "build/packages"
version := `sed -n 's/^version = "\(.*\)"/\1/p' typst.toml`

# Nix sets SOURCE_DATE_EPOCH to 1980 for reproducible builds, and Typst would then date every document in 1980. It is
# unset so that `datetime.today()` and the PDF creation date use the actual date.
typst := "env -u SOURCE_DATE_EPOCH typst"

[private]
default:
    @just --list --unsorted

[group("build")]
[doc("Expose the working tree as @preview/quire:<version>, so that the template and examples compile against it.")]
link:
    mkdir -p {{packages}}/preview/quire
    ln -sfn "$PWD" {{packages}}/preview/quire/{{version}}

[group("build")]
[doc("Compile the examples next to their sources.")]
examples: link
    for file in examples/*.typ; do {{typst}} compile --package-path {{packages}} "$file"; done

[group("build")]
[doc("Compile the user manual (after the examples, whose pages it shows).")]
manual: examples
    {{typst}} compile --root . docs/manual.typ docs/manual.pdf

[group("build")]
[doc("Compile the PDFs committed to the repository: the examples and the manual.")]
pdfs: examples manual

[group("build")]
[doc("Compile the template of `typst init` and render the thumbnail from its first page.")]
template: link
    mkdir -p build
    {{typst}} compile --package-path {{packages}} template/main.typ build/template.pdf
    {{typst}} compile --package-path {{packages}} --pages 1 --ppi 250 template/main.typ thumbnail.png

[group("build")]
[doc("Compile everything.")]
build: pdfs template

[group("build")]
[doc("Watch a file and recompile it on changes, e.g. `just watch examples/article.typ`.")]
watch file: link
    {{typst}} watch --root . --package-path {{packages}} {{file}}

[group("lint")]
[doc("Format the Typst sources.")]
format:
    typstyle --inplace --line-width 120 src docs examples template

[group("lint")]
[doc("Run all the git hooks on every file.")]
check:
    prek run --all-files
