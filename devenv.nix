{
  pkgs,
  lib,
  config,
  ...
}: {
  # Typst toolchain: compiler, `typstyle` formatter and `tinymist` language server. The fonts used by the default
  # style are *not* provided here: they are expected to be installed system-wide (see the README).
  languages.typst.enable = true;

  # Core development tools.
  packages = with pkgs; [
    git
    just
  ];

  # Git hooks, installed when entering the shell.
  git-hooks.hooks = {
    # Enforce Conventional Commits on commit messages.
    convco.enable = true;

    # Check Typst formatting.
    typstyle = {
      enable = true;
      name = "typstyle";
      description = "Check Typst formatting with typstyle";
      entry = "${pkgs.typstyle}/bin/typstyle --check --line-width 120";
      files = "\\.typ$";
    };

    # Keep the committed PDFs (manual and examples) and the README preview in sync with their sources: when a source is staged, rebuild the
    # PDFs; if any of them changes, the commit is aborted so that the updated PDFs can be staged too. The build is
    # deterministic, so unchanged sources give byte-identical PDFs. It uses the system fonts.
    pdfs = {
      enable = true;
      name = "pdfs";
      description = "Rebuild the committed PDFs when their sources change";
      entry = toString (pkgs.writeShellScript "build-pdfs" ''
        export PATH=${lib.makeBinPath [config.languages.typst.package pkgs.just pkgs.gnused pkgs.coreutils]}:$PATH
        exec just pdfs
      '');
      files = "^(src/|docs/|examples/|typst\\.toml$)";
      pass_filenames = false;
    };

    # Check Markdown files.
    markdownlint = {
      enable = true;
      settings.configuration = {
        MD013.line_length = 120;
      };
    };

    # Format Nix files.
    alejandra.enable = true;

    # Validate TOML files (e.g. `typst.toml`).
    check-toml.enable = true;
  };

  enterShell = ''
    # Nix sets SOURCE_DATE_EPOCH to 1980 for reproducible builds; Typst would then date every document in 1980.
    unset SOURCE_DATE_EPOCH
    echo "quire development environment — run 'just' to list the available recipes."
  '';
}
