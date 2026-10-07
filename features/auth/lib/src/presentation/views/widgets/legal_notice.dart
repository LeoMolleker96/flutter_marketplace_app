part of '../login_view.dart';

/// Terms and privacy line.
///
/// The links are styled but not tappable yet — there is nowhere to send anyone.
class _LegalNotice extends StatelessWidget {
  const _LegalNotice();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = context.textStyles.bodySmall?.copyWith(color: colors.outline);
    final link = base?.copyWith(decoration: TextDecoration.underline);

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: "By continuing, you agree to Agora's "),
          TextSpan(text: 'Terms of Service', style: link),
          const TextSpan(text: ' & '),
          TextSpan(text: 'Privacy Policy', style: link),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
