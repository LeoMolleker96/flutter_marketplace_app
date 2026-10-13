import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Horizontal rule with a caption centred in it.
///
/// The caption is a parameter because the screens that share this word it
/// differently ("Or Continue With" on sign-in, "o" on sign-up).
class TextDivider extends StatelessWidget {
  /// Creates a divider captioned with [text].
  const TextDivider(this.text, {super.key});

  /// The caption shown between the two rules.
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colors.surfaceContainerHighest,
            height: 1,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            text,
            style: context.textStyles.labelSmall?.copyWith(
              color: colors.outline,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colors.surfaceContainerHighest,
            height: 1,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
