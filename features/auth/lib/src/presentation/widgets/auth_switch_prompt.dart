import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// The line that sends someone to the other authentication screen: "Don't have
/// an account? Sign up" on sign-in, "¿Ya tienes cuenta? Inicia sesión" on
/// sign-up.
///
/// One widget for both directions because they are the same sentence turned
/// around: a question, then a link that answers it.
class AuthSwitchPrompt extends StatelessWidget {
  /// Creates the prompt.
  const AuthSwitchPrompt({
    required this.question,
    required this.actionLabel,
    required this.onTap,
    super.key,
  });

  /// The question, without a trailing space.
  final String question;

  /// The link's text.
  final String actionLabel;

  /// Called when the link is tapped. Where it goes is the app shell's decision.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // A Wrap rather than a Row: the two pieces are one sentence, and a Row
    // would overflow rather than break the line when the text is long — under
    // a large system text scale, or once this string is translated.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$question ',
          style: context.textStyles.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: context.textStyles.bodyMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
