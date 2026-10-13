import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// The app's Material theme.
///
/// Only a light theme exists because the design system defines only a light
/// palette. A dark theme needs its own set of tokens rather than a guess.
abstract final class AppTheme {
  /// The single theme the app runs on.
  static ThemeData get light => ThemeData(
        colorScheme: AppColors.light,
        textTheme: AppTypography.textTheme,
        fontFamily: AppTypography.fontFamily,
        package: AppTypography.fontPackage,
        scaffoldBackgroundColor: AppColors.surface,
      );
}
