import 'package:flutter/material.dart';
import 'package:marketplace_app/core/theme/app_spacing.dart';
import 'package:marketplace_app/core/theme/theme_context_extension.dart';

/// The design system's checkbox with its label — the "Remember me" control.
///
/// Controlled: it renders [value] and reports taps through [onChanged], it
/// never holds the state itself. The whole row is the tap target, not just the
/// 20px box.
class AppCheckbox extends StatelessWidget {
  /// Creates a labelled checkbox.
  const AppCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
  });

  /// Whether the box is checked.
  final bool value;

  /// Called with the new value when tapped.
  final ValueChanged<bool> onChanged;

  /// Text shown beside the box.
  final String label;

  /// Fixed by the design; not a spacing token.
  static const _size = 20.0;

  /// The design's one documented exception to the radius scale.
  static const _radius = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(_radius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: value ? colors.primaryContainer : colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: value
                ? Icon(Icons.check, size: 16, color: colors.onPrimary)
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: context.textStyles.labelMedium?.copyWith(
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
