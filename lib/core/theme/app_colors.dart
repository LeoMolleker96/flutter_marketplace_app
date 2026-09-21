import 'package:flutter/material.dart';

/// The design system palette, verbatim from `DESIGN.md`.
///
/// Prefer reading colours through `context.colors` rather than referencing
/// these constants directly — the [ColorScheme] is what widgets and Material
/// components resolve against.
abstract final class AppColors {
  // Surfaces
  static const surface = Color(0xFFFAF8FF);
  static const surfaceDim = Color(0xFFD2D9F4);
  static const surfaceBright = Color(0xFFFAF8FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF2F3FF);
  static const surfaceContainer = Color(0xFFEAEDFF);
  static const surfaceContainerHigh = Color(0xFFE2E7FF);
  static const surfaceContainerHighest = Color(0xFFDAE2FD);
  static const onSurface = Color(0xFF131B2E);
  static const onSurfaceVariant = Color(0xFF464555);
  static const inverseSurface = Color(0xFF283044);
  static const inverseOnSurface = Color(0xFFEEF0FF);
  static const outline = Color(0xFF777587);
  static const outlineVariant = Color(0xFFC7C4D8);
  static const surfaceTint = Color(0xFF4D44E3);

  // Primary
  static const primary = Color(0xFF3525CD);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF4F46E5);
  static const onPrimaryContainer = Color(0xFFDAD7FF);
  static const inversePrimary = Color(0xFFC3C0FF);
  static const primaryFixed = Color(0xFFE2DFFF);
  static const primaryFixedDim = Color(0xFFC3C0FF);
  static const onPrimaryFixed = Color(0xFF0F0069);
  static const onPrimaryFixedVariant = Color(0xFF3323CC);

  // Secondary
  static const secondary = Color(0xFF006591);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFF39B8FD);
  static const onSecondaryContainer = Color(0xFF004666);
  static const secondaryFixed = Color(0xFFC9E6FF);
  static const secondaryFixedDim = Color(0xFF89CEFF);
  static const onSecondaryFixed = Color(0xFF001E2F);
  static const onSecondaryFixedVariant = Color(0xFF004C6E);

  // Tertiary
  static const tertiary = Color(0xFF005338);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF006E4B);
  static const onTertiaryContainer = Color(0xFF67F4B7);
  static const tertiaryFixed = Color(0xFF6FFBBE);
  static const tertiaryFixedDim = Color(0xFF4EDEA3);
  static const onTertiaryFixed = Color(0xFF002113);
  static const onTertiaryFixedVariant = Color(0xFF005236);

  // Error
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  /// Every palette entry above, wired into the scheme Material resolves.
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    primaryFixed: primaryFixed,
    primaryFixedDim: primaryFixedDim,
    onPrimaryFixed: onPrimaryFixed,
    onPrimaryFixedVariant: onPrimaryFixedVariant,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    secondaryFixed: secondaryFixed,
    secondaryFixedDim: secondaryFixedDim,
    onSecondaryFixed: onSecondaryFixed,
    onSecondaryFixedVariant: onSecondaryFixedVariant,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    tertiaryFixed: tertiaryFixed,
    tertiaryFixedDim: tertiaryFixedDim,
    onTertiaryFixed: onTertiaryFixed,
    onTertiaryFixedVariant: onTertiaryFixedVariant,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    surfaceDim: surfaceDim,
    surfaceBright: surfaceBright,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    inverseSurface: inverseSurface,
    onInverseSurface: inverseOnSurface,
    inversePrimary: inversePrimary,
    surfaceTint: surfaceTint,
  );
}
