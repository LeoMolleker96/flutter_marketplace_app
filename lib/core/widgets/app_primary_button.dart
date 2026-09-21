import 'package:flutter/material.dart';
import 'package:marketplace_app/core/theme/app_spacing.dart';
import 'package:marketplace_app/core/theme/theme_context_extension.dart';

/// The design system's primary call to action — the "Sign In" button.
///
/// Built as a gradient container rather than a `FilledButton` because the
/// design fills it from `primary` to `primaryContainer`, which Material's
/// button themes cannot express.
///
/// Whether the action is currently available is the caller's decision, passed
/// as [enabled] — the button never infers it.
class AppPrimaryButton extends StatelessWidget {
  /// Creates a primary button.
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.icon = Icons.arrow_forward,
    super.key,
  });

  /// Text shown on the button.
  final String label;

  /// Tap handler. Always provided; [enabled] decides whether it can fire.
  final VoidCallback onPressed;

  /// Whether the button accepts taps and renders as available.
  final bool enabled;

  /// Trailing icon; pass null for a label-only button.
  final IconData? icon;

  /// Fixed by the design; not a spacing token.
  static const _height = 52.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = this.icon;

    // Disabled swaps the fill and the foreground rather than fading the whole
    // widget. Opacity is the obvious way to do this and the wrong one: any
    // value between 0 and 1 forces the compositor into an offscreen buffer
    // (saveLayer) for every frame the widget is alive. It also dims the
    // gradient instead of neutralising it, which reads as "washed out" rather
    // than "unavailable".
    //
    // The disabled values follow Material 3: 12% of onSurface for the fill,
    // 38% for the label.
    final foreground =
        enabled ? colors.onPrimary : colors.onSurface.withValues(alpha: 0.38);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: enabled
            ? LinearGradient(colors: [colors.primary, colors.primaryContainer])
            : null,
        color: enabled ? null : colors.onSurface.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SizedBox(
            height: _height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: context.textStyles.labelLarge?.copyWith(
                    color: foreground,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(icon, size: 18, color: foreground),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
