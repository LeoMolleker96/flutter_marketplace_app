import 'package:flutter/material.dart';
import 'package:marketplace_app/core/theme/theme_context_extension.dart';

/// Screen title — the "Welcome back" line.
///
/// These three widgets exist so a screen never writes a `TextStyle` by hand.
/// Using them is what keeps family, size and colour identical everywhere.
class AppTitle extends StatelessWidget {
  /// Creates a screen title.
  const AppTitle(this.text, {this.textAlign = TextAlign.center, super.key});

  /// The text to render.
  final String text;

  /// How the text aligns within its box.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: context.textStyles.displayMedium?.copyWith(
        color: context.colors.onSurface,
      ),
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
