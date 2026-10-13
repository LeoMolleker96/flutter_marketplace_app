import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MaxLengthEnforcement;

import '../theme/app_spacing.dart';
import '../theme/theme_context_extension.dart';

/// The design system's text field: a small label above a filled input with a
/// leading icon.
///
/// Covers the fields on the sign-in and sign-up screens. The password case is
/// [obscurable]: it hides the text and adds the eye toggle, which is the only
/// state this widget owns.
///
/// [labelAction] fills the space opposite the label, where the design puts
/// "Forgot password?".
class AppTextField extends StatefulWidget {
  /// Creates a text field.
  const AppTextField({
    required this.label,
    required this.hintText,
    required this.icon,
    this.controller,
    this.obscurable = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.autofillHints,
    this.onSubmitted,
    this.maxLength,
    this.labelAction,
    this.errorText,
    super.key,
  });

  /// Small label rendered above the field.
  final String label;

  /// Placeholder shown while the field is empty.
  final String hintText;

  /// Leading icon inside the field.
  final IconData icon;

  /// Holds the entered text.
  final TextEditingController? controller;

  /// Hides the text and shows a visibility toggle.
  final bool obscurable;

  /// Keyboard variant to request.
  final TextInputType? keyboardType;

  /// What the keyboard's action key does.
  final TextInputAction? textInputAction;

  /// Focus owner for this field, so a form can move focus between its fields.
  ///
  /// The caller creates and disposes it; the field only uses it. Null leaves
  /// Flutter to manage an internal one.
  final FocusNode? focusNode;

  /// What the platform's autofill service may put in this field.
  ///
  /// Without hints, password managers can neither fill nor offer to generate a
  /// password. The field does not know what it collects, so the form says so
  /// (for example `AutofillHints.password`). Only takes effect inside an
  /// `AutofillGroup`.
  final Iterable<String>? autofillHints;

  /// Called when the user submits from the keyboard (Enter on the web, the
  /// action key on mobile).
  ///
  /// Without it, Enter does nothing useful on a form that is otherwise only
  /// submittable by clicking.
  final ValueChanged<String>? onSubmitted;

  /// Longest text the field accepts; anything beyond it is refused as typed or
  /// pasted.
  ///
  /// A hard limit, not a hint: it bounds the work validation does on every
  /// keystroke. Flutter's character counter is deliberately not shown.
  final int? maxLength;

  /// Optional trailing widget on the label row.
  final Widget? labelAction;

  /// Why the current text is not acceptable, or null when nothing is wrong.
  ///
  /// The caller decides when to show it — usually only once the user has typed
  /// something, so an untouched form does not open already complaining. When set,
  /// the field takes an error-coloured border and the message appears under it.
  final String? errorText;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  /// Fixed by the design; not a spacing token.
  static const _height = 56.0;

  late bool _obscured = widget.obscurable;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labelAction = widget.labelAction;
    final errorText = widget.errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Text(
                widget.label,
                style: context.textStyles.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              if (labelAction != null) ...[const Spacer(), labelAction],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: _height,
          child: TextField(
            controller: widget.controller,
            obscureText: _obscured,
            focusNode: widget.focusNode,
            // While the password is revealed it sits in plain text, so the
            // keyboard is asked not to treat it as prose. While obscured, the
            // configured type is kept: the platform already treats an obscured
            // field as a password.
            keyboardType: widget.obscurable && !_obscured
                ? TextInputType.visiblePassword
                : widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            onSubmitted: widget.onSubmitted,
            maxLength: widget.maxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            // A password must never reach the keyboard's learned vocabulary, so
            // this holds whether it is obscured or revealed by the eye toggle.
            autocorrect: !widget.obscurable,
            enableSuggestions: !widget.obscurable,
            style: context.textStyles.bodyLarge?.copyWith(
              color: colors.onSurface,
            ),
            decoration: InputDecoration(
              // Hides the "12/254" counter that maxLength adds: the field has a
              // fixed height, and the limit is a safeguard, not something to
              // show.
              counterText: '',
              hintText: widget.hintText,
              hintStyle: context.textStyles.bodyLarge?.copyWith(
                color: colors.outline,
              ),
              filled: true,
              fillColor: colors.surfaceContainerLow,
              prefixIcon: Icon(widget.icon, size: 20, color: colors.outline),
              suffixIcon: widget.obscurable
                  ? IconButton(
                      onPressed: () => setState(() => _obscured = !_obscured),
                      icon: Icon(
                        _obscured ? Icons.visibility : Icons.visibility_off,
                        size: 20,
                        color: colors.outline,
                      ),
                      tooltip: _obscured ? 'Show password' : 'Hide password',
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: errorText == null
                    ? BorderSide.none
                    : BorderSide(color: colors.error),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: errorText == null
                      ? colors.primaryContainer
                      : colors.error,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        // Drawn here rather than through InputDecoration.errorText: the field
        // above has a fixed height, and Material's error line would be squeezed
        // into it instead of sitting underneath.
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              top: AppSpacing.xs,
            ),
            // A live region so a screen reader announces the message when it
            // appears. It is not part of the TextField, so without this it
            // would be silent to someone who cannot see the red text.
            child: Semantics(
              liveRegion: true,
              child: Text(
                errorText,
                style: context.textStyles.bodySmall?.copyWith(
                  color: colors.error,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
