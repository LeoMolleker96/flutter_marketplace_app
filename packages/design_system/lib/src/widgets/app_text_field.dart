import 'package:flutter/material.dart';
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
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            style: context.textStyles.bodyLarge?.copyWith(
              color: colors.onSurface,
            ),
            decoration: InputDecoration(
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
                  color: errorText == null ? colors.primaryContainer : colors.error,
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
