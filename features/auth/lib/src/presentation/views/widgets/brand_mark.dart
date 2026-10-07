part of '../login_view.dart';

/// The app logo with its verified badge.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  static const _logoSize = 64.0;
  static const _badgeSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      // Room for the badge, which overhangs the logo by half its own size.
      width: _logoSize + AppSpacing.sm,
      height: _logoSize + AppSpacing.sm,
      child: Stack(
        children: [
          Container(
            width: _logoSize,
            height: _logoSize,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 32,
              color: colors.onPrimary,
            ),
          ),
          Positioned(
            top: _logoSize - _badgeSize,
            left: _logoSize - _badgeSize,
            child: Container(
              width: _badgeSize,
              height: _badgeSize,
              decoration: BoxDecoration(
                color: colors.tertiaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, size: 14, color: colors.onTertiary),
            ),
          ),
        ],
      ),
    );
  }
}
