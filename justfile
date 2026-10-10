set unstable

# Directory where the package is exposed as `@preview/quire` for local compilation.
packages := "build/packages"
version := `sed -n 's/^version = "\(.*\)"/\1/p' typst.toml`

[private]
default:
    @just --list --unsorted

[group("package")]
[doc("Expose the working tree as @preview/quire:<version>, so that the template and examples compile against it.")]
link:
    mkdir -p {{packages}}/preview/quire
    ln -sfn "$PWD" {{packages}}/preview/quire/{{version}}

[group("package")]
[doc("Compile the user manual.")]
manual:
    mkdir -p build
    typst compile --root . docs/manual.typ docs/manual.pdf

[group("package")]
[doc("Compile the examples.")]
examples: link
    for file in examples/*.typ; do \
        typst compile --package-path {{packages}} "$file" "build/$(basename "$file" .typ).pdf"; \
    done

[group("package")]
[doc("Compile the template of `typst init` and render the thumbnail from its first page.")]
template: link
    typst compile --package-path {{packages}} template/main.typ build/template.pdf
    typst compile --package-path {{packages}} --pages 1 --ppi 250 template/main.typ thumbnail.png

[group("package")]
[doc("Compile everything.")]
build: manual examples template

[group("package")]
[doc("Watch a file and recompile it on changes, e.g. `just watch examples/article.typ`.")]
watch file: link
    typst watch --root . --package-path {{packages}} {{file}} build/$(basename {{file}} .typ).pdf

[group("lint")]
[doc("Format the Typst sources.")]
format:
    typstyle --inplace --line-width 120 src docs examples template

[group("lint")]
[doc("Run all the git hooks on every file.")]
check:
    prek run --all-files
