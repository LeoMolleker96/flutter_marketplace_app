import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Terms and privacy line.
///
/// The links are styled but not tappable yet — there is nowhere to send anyone.
///
/// The sentence is assembled from parameters because sign-in and sign-up word
/// it differently, but the shape is the same: an opening, the terms link, a
/// connector, the privacy link and a full stop.
class LegalNotice extends StatelessWidget {
  /// Creates the notice from the pieces of its sentence.
  const LegalNotice({
    required this.opening,
    required this.termsLabel,
    required this.connector,
    required this.privacyLabel,
    super.key,
  });

  /// Text before the terms link, trailing space included.
  final String opening;

  /// Text of the terms link.
  final String termsLabel;

  /// Text between the two links, spaces included.
  final String connector;

  /// Text of the privacy link.
  final String privacyLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = context.textStyles.bodySmall?.copyWith(color: colors.outline);
    final link = base?.copyWith(decoration: TextDecoration.underline);

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: opening),
          TextSpan(text: termsLabel, style: link),
          TextSpan(text: connector),
          TextSpan(text: privacyLabel, style: link),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
