import 'package:flutter/material.dart';

import '../layout/window_size_class.dart';
import '../theme/theme_context_extension.dart';

/// Screen title — the "Welcome back" line.
///
/// These three widgets exist so a screen never writes a `TextStyle` by hand.
/// Using them is what keeps family, size and colour identical everywhere.
///
/// The size follows the window: the 32 px mobile style below
/// [WindowSizeClass.expanded], the 40 px desktop style from there up.
class AppTitle extends StatelessWidget {
  /// Creates a screen title.
  const AppTitle(this.text, {this.textAlign = TextAlign.center, super.key});

  /// The text to render.
  final String text;

  /// How the text aligns within its box.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    // Material has no responsive display slot, so the theme maps the desktop
    // style to displayLarge and the mobile one to displayMedium
    // (AppTypography.textTheme).
    final isWide = context.windowSizeClass.isAtLeast(WindowSizeClass.expanded);
    final style = isWide
        ? context.textStyles.displayLarge
        : context.textStyles.displayMedium;

    return Text(
      text,
      textAlign: textAlign,
      style: style?.copyWith(color: context.colors.onSurface),
    );
  }
}

/// Supporting line under an [AppTitle].
class AppSubtitle extends StatelessWidget {
  /// Creates a subtitle.
  const AppSubtitle(this.text, {this.textAlign = TextAlign.center, super.key});

  /// The text to render.
  final String text;

  /// How the text aligns within its box.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: context.textStyles.bodyMedium?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    );
  }
}

/// Small print at the bottom of a screen — legal lines and disclaimers.
class AppFootnote extends StatelessWidget {
  /// Creates a footnote.
  const AppFootnote(this.text, {this.textAlign = TextAlign.center, super.key});

  /// The text to render.
  final String text;

  /// How the text aligns within its box.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: context.textStyles.bodySmall?.copyWith(
        color: context.colors.outline,
      ),
    );
  }
}
