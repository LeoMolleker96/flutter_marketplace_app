import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// "Continue with Google" button.
///
/// The [label] is a parameter because sign-in and sign-up word it differently.
class GoogleButton extends StatelessWidget {
  /// Creates the button with [label] as its text.
  const GoogleButton(this.label, {super.key});

  /// The text next to the Google mark.
  final String label;

  /// Google's blue, which is fixed by their brand guidelines and therefore not
  /// a theme colour.
  static const _googleBlue = Color(0xFF4285F4);

  /// Fixed by the design; matches the primary button's height.
  static const _height = 52.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Material(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        elevation: 1,
        shadowColor: colors.onSurface.withValues(alpha: 0.08),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            height: _height,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'G',
                  style: context.textStyles.titleLarge?.copyWith(
                    color: _googleBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Flexible so a long label wraps instead of overflowing the row:
                // the Spanish wording is wider than the English one, and a
                // narrow phone leaves the button little room.
                Flexible(
                  child: Text(
                    label,
                    style: context.textStyles.labelMedium?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
