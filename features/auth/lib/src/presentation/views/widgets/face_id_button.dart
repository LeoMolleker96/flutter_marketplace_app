part of '../login_view.dart';

/// Biometric shortcut pill.
class _FaceIdButton extends StatelessWidget {
  const _FaceIdButton();

  /// Off the spacing scale: the design sets this pill's vertical padding to 6.
  static const _verticalPadding = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.base),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppRadius.base),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: _verticalPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.face_outlined, size: 18, color: colors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Face ID',
                style: context.textStyles.labelSmall?.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
