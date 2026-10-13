part of '../sign_up_view.dart';

/// The list of conditions a new password must meet, each turning from red to
/// green as the password satisfies it.
///
/// It is shown from the start, all red, so the person sees what is expected
/// before typing instead of learning it from a rejection. Colour is not the only
/// signal: a met requirement also swaps its icon, and a screen reader hears
/// whether each one is done.
///
/// Stateless: it is handed the current password and decides nothing itself. What
/// counts as met is `PasswordRequirement.isMetBy`, in `domain`.
class _PasswordRequirements extends StatelessWidget {
  const _PasswordRequirements(this.password);

  /// The text typed so far in the password field.
  final String password;

  static const _iconSize = 16.0;

  /// The wording for [requirement].
  ///
  /// A `switch` over the enum, so a new requirement does not compile until it
  /// has a label here.
  static String _labelFor(PasswordRequirement requirement) {
    return switch (requirement) {
      PasswordRequirement.minLength =>
        'Mínimo ${SignUpRules.minPasswordLength} caracteres',
      PasswordRequirement.uppercase => 'Una letra mayúscula',
      PasswordRequirement.number => 'Un número',
      PasswordRequirement.symbol => 'Un símbolo, como ! ? # @',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        top: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final requirement in PasswordRequirement.values)
            _RequirementRow(
              label: _labelFor(requirement),
              isMet: requirement.isMetBy(password),
            ),
        ],
      ),
    );
  }
}

/// One line of the list: an icon and its text, in green or red.
class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.label, required this.isMet});

  final String label;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isMet ? colors.tertiaryContainer : colors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      // One announcement per line, with the state in words, instead of an icon
      // and a text read separately and the colour lost.
      child: Semantics(
        label: '$label: ${isMet ? 'cumplido' : 'pendiente'}',
        excludeSemantics: true,
        child: Row(
          children: [
            Icon(
              isMet ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: _PasswordRequirements._iconSize,
              color: color,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: context.textStyles.bodySmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
