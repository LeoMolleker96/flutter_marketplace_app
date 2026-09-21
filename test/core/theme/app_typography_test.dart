import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/core/theme/app_typography.dart';

void main() {
  group('type scale', () {
    test('every style uses the one family', () {
      final styles = [
        AppTypography.displayLg,
        AppTypography.displayLgMobile,
        AppTypography.headlineLg,
        AppTypography.headlineMd,
        AppTypography.headlineSm,
        AppTypography.bodyLg,
        AppTypography.bodyMd,
        AppTypography.bodySm,
        AppTypography.labelLg,
        AppTypography.labelMd,
        AppTypography.labelSm,
      ];

      for (final style in styles) {
        expect(style.fontFamily, 'Plus Jakarta Sans');
      }
    });

    test('carries the sizes and weights from the design tokens', () {
      expect(AppTypography.displayLgMobile.fontSize, 32);
      expect(AppTypography.displayLgMobile.fontWeight, FontWeight.w800);

      expect(AppTypography.bodyMd.fontSize, 14);
      expect(AppTypography.bodyMd.fontWeight, FontWeight.w400);

      expect(AppTypography.labelSm.fontSize, 11);
      expect(AppTypography.labelSm.fontWeight, FontWeight.w700);
    });
  });

  group('unit conversion', () {
    // The design states line height in absolute pixels and tracking in `em`.
    // Flutter wants a multiplier and logical pixels respectively, so these two
    // conversions are the only real logic in the file — and the easiest place
    // for a silent visual bug to hide.
    test('converts line height to a multiplier', () {
      expect(AppTypography.displayLgMobile.height, closeTo(40 / 32, 0.0001));
      expect(AppTypography.bodyMd.height, closeTo(20 / 14, 0.0001));
      expect(AppTypography.labelSm.height, closeTo(14 / 11, 0.0001));
    });

    test('converts em tracking to logical pixels', () {
      // -0.03em at 32px
      expect(AppTypography.displayLgMobile.letterSpacing, closeTo(-0.96, 0.0001));
      // -0.01em at 14px
      expect(AppTypography.bodyMd.letterSpacing, closeTo(-0.14, 0.0001));
      // +0.01em at 11px
      expect(AppTypography.labelSm.letterSpacing, closeTo(0.11, 0.0001));
    });

    test('gives labels neutral tracking', () {
      expect(AppTypography.labelLg.letterSpacing, 0);
      expect(AppTypography.labelMd.letterSpacing, 0);
    });
  });

  group('textTheme', () {
    test('maps the design tokens onto Material slots', () {
      final theme = AppTypography.textTheme;

      expect(theme.displayLarge, AppTypography.displayLg);
      expect(theme.displayMedium, AppTypography.displayLgMobile);
      expect(theme.headlineLarge, AppTypography.headlineLg);
      expect(theme.bodyMedium, AppTypography.bodyMd);
      expect(theme.labelSmall, AppTypography.labelSm);
    });
  });
}
