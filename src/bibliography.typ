/// This module configures citations and the bibliography.
#import "i18n.typ": translate

/// Applies the bibliography settings: alphanumeric citation keys, a variant of the IEEE style, and a localized,
/// unnumbered title at the level of chapters (or sections, without chapters).
///
/// -> content
#let _bibliography-setup(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The content to apply the settings to.
  /// -> content
  body,
) = {
  set cite(style: "alphanumeric")
  set bibliography(title: translate("bibliography"), style: "assets/quire.csl")

  let level = cfg.levels.at("chapter", default: cfg.levels.section)
  show bibliography: set heading(numbering: none, offset: level - 1)

  body
}
