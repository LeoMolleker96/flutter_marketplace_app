import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// The inline message that tells the user why an authentication attempt failed.
///
/// Purely presentational: it renders [message], or nothing when it is null. Each
/// screen decides what the message says, because that depends on its controller
/// and its language; the look of the notice is shared so the two cannot drift.
class AuthErrorNotice extends StatelessWidget {
  /// Creates the notice. A null [message] renders nothing.
  const AuthErrorNotice(this.message, {super.key});

  /// What to tell the person, or null when there is nothing to report.
  final String? message;

  static const _iconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final message = this.message;

    if (message == null) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      // A live region so a screen reader announces the failure when it appears,
      // instead of leaving the user to discover it.
      child: Semantics(
        liveRegion: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, size: _iconSize, color: colors.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: context.textStyles.bodySmall?.copyWith(
                  color: colors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
