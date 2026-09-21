import 'package:flutter/material.dart';

/// Shorthand access to the theme.
///
/// `context.colors.primary` instead of `Theme.of(context).colorScheme.primary`,
/// and `context.textStyles.labelSm` instead of
/// `Theme.of(context).textTheme.labelSmall`.
///
/// Always read colours and text styles through this rather than importing
/// `AppColors` or `AppTypography` into a widget: going through the theme is
/// what will let a second theme be introduced later without touching any UI.
extension ThemeContext on BuildContext {
  /// The active colour scheme.
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// The active type scale.
  TextTheme get textStyles => Theme.of(this).textTheme;
}
