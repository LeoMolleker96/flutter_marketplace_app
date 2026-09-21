import 'package:flutter/material.dart';

/// The design system's type scale, verbatim from `DESIGN.md`.
///
/// Every style is Plus Jakarta Sans; sizes, weights, line heights and tracking
/// come straight from the tokens. Read them through `context.textStyles`.
abstract final class AppTypography {
  /// The single family used across the whole app.
  static const fontFamily = 'Plus Jakarta Sans';

  /// 40 / 800 — desktop hero headings.
  static final displayLg = _style(size: 40, lineHeight: 48, weight: FontWeight.w800, tracking: -0.03);

  /// 32 / 800 — the mobile variant of [displayLg]; used for screen titles.
  static final displayLgMobile = _style(size: 32, lineHeight: 40, weight: FontWeight.w800, tracking: -0.03);

  /// 28 / 700.
  static final headlineLg = _style(size: 28, lineHeight: 36, weight: FontWeight.w700, tracking: -0.02);

  /// 22 / 600.
  static final headlineMd = _style(size: 22, lineHeight: 30, weight: FontWeight.w600, tracking: -0.02);

  /// 18 / 600 — card and list item titles.
  static final headlineSm = _style(size: 18, lineHeight: 26, weight: FontWeight.w600, tracking: -0.02);

  /// 16 / 400 — text the user types into inputs.
  static final bodyLg = _style(size: 16, lineHeight: 24, weight: FontWeight.w400, tracking: -0.01);

  /// 14 / 400 — default body copy.
  static final bodyMd = _style(size: 14, lineHeight: 20, weight: FontWeight.w400, tracking: -0.01);

  /// 12 / 400 — legal and disclaimer text.
  static final bodySm = _style(size: 12, lineHeight: 18, weight: FontWeight.w400, tracking: -0.01);

  /// 14 / 600 — button labels.
  static final labelLg = _style(size: 14, lineHeight: 20, weight: FontWeight.w600, tracking: 0);

  /// 12 / 600 — inline control labels such as "Remember me".
  static final labelMd = _style(size: 12, lineHeight: 16, weight: FontWeight.w600, tracking: 0);

  /// 11 / 700 — field labels and micro badges.
  static final labelSm = _style(size: 11, lineHeight: 14, weight: FontWeight.w700, tracking: 0.01);

  /// The scale mapped onto Material's slots, so stock widgets inherit it too.
  ///
  /// [displayLgMobile] takes `displayMedium` because Material has no slot for a
  /// responsive variant of a display style.
  static final textTheme = TextTheme(
    displayLarge: displayLg,
    displayMedium: displayLgMobile,
    headlineLarge: headlineLg,
    headlineMedium: headlineMd,
    headlineSmall: headlineSm,
    titleLarge: headlineSm,
    bodyLarge: bodyLg,
    bodyMedium: bodyMd,
    bodySmall: bodySm,
    labelLarge: labelLg,
    labelMedium: labelMd,
    labelSmall: labelSm,
  );

  /// Tracking in the design is expressed in `em`, which Flutter wants in
  /// logical pixels, and line height as an absolute value, which Flutter wants
  /// as a multiplier. Both conversions happen here so the callers above can
  /// stay identical to the design tokens.
  static TextStyle _style({
    required double size,
    required double lineHeight,
    required FontWeight weight,
    required double tracking,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: tracking * size,
    );
  }
}
