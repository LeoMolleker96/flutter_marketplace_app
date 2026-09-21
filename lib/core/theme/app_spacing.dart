/// Spacing and corner radius tokens, verbatim from `DESIGN.md`.
///
/// Values are logical pixels; the design expresses them in `rem` at the usual
/// 16px root, so `1rem` is `16`.
///
/// No spacing or radius literal should appear in a widget. If a value is
/// missing here, it is either a component dimension (a field's height, an icon
/// size) that belongs next to that component, or a token the design does not
/// actually define — and inventing one is how a design system drifts.
library;

/// The 8pt spacing scale, with a 4pt sub-grid for tight inline alignment.
abstract final class AppSpacing {
  /// 4 — between paired inline icons and their text.
  static const xs = 4.0;

  /// 8 — between a field label and its input; gaps inside chips.
  static const sm = 8.0;

  /// 16 — padding inside cards, standard form stacking.
  static const md = 16.0;

  /// 24 — separation between sections within a card.
  static const lg = 24.0;

  /// 32 — separation between layout modules.
  static const xl = 32.0;

  /// 16 — column gutter on tablet and up.
  static const gutter = 16.0;

  /// 12 — column gutter on mobile.
  static const gutterMobile = 12.0;

  /// 24 — screen side margin on tablet and up.
  static const margin = 24.0;

  /// 16 — screen side margin on mobile.
  static const marginMobile = 16.0;
}

/// Corner radii.
///
/// [base] is the design's `DEFAULT`. Checkboxes are the one documented
/// exception at 6px, which is declared in the checkbox itself.
abstract final class AppRadius {
  /// 4.
  static const sm = 4.0;

  /// 8.
  static const base = 8.0;

  /// 12 — input fields.
  static const md = 12.0;

  /// 16 — cards, primary buttons, social buttons.
  static const lg = 16.0;

  /// 24 — large surface panels.
  static const xl = 24.0;

  /// Pill shapes: chips, FABs, avatars.
  static const full = 9999.0;
}
