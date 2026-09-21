import 'package:flutter/material.dart';
import 'package:marketplace_app/core/theme/app_spacing.dart';
import 'package:marketplace_app/core/theme/theme_context_extension.dart';

/// The design system's text field: a small label above a filled input with a
/// leading icon.
///
/// Covers both fields on the sign-in screen. The password case is
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
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: colors.primaryContainer, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
