part of '../login_view.dart';

/// Horizontal rule with a caption centred in it.
class _TextDivider extends StatelessWidget {
  const _TextDivider();

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
            'Or Continue With',
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
