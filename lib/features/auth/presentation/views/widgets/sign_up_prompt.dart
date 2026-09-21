part of '../login_view.dart';

/// "Don't have an account? Sign up".
class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt();

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
          "Don't have an account? ",
          style: context.textStyles.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        InkWell(
          onTap: () {},
          child: Text(
            'Sign up',
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
