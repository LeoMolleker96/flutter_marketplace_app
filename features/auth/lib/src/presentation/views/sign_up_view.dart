import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/params/sign_up_params.dart';
import '../../domain/rules/sign_up_rules.dart';
import '../view_models/sign_up_controller.dart';
import '../widgets/auth_error_notice.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/google_button.dart';
import '../widgets/legal_notice.dart';
import '../widgets/text_divider.dart';

// The sections only this screen uses live in their own files but stay part of
// this library, which is what lets them remain private to it. Every import the
// parts need is declared above; a part file cannot have imports of its own.
part 'widgets/password_requirements.dart';

part 'widgets/sign_up_error.dart';

part 'widgets/sign_up_form.dart';

/// The sign-up screen.
///
/// Collects an email and a password (twice) and hands them to
/// `SignUpController`; it does not create the account itself. What it owns is
/// ephemeral UI state — the three pieces of text being typed — which nothing
/// outside this screen reads. The rules those texts must satisfy come from
/// `SignUpRules` in `domain`, so the screen decides how to show them and not what
/// they are.
///
/// Knows nothing about where a new user goes next, or where "Inicia sesión"
/// leads: the app shell hands in [onSignedUp] and [onSignInTapped]. This is what
/// keeps the auth feature from depending on any other feature or on the router.
class SignUpView extends ConsumerStatefulWidget {
  /// Creates the sign-up screen.
  const SignUpView({
    required this.onSignedUp,
    required this.onSignInTapped,
    super.key,
  });

  /// Called once, when an attempt succeeds: the account exists and the user is
  /// signed in.
  ///
  /// Not called when the attempt fails or while it is still in flight.
  final VoidCallback onSignedUp;

  /// Called when the user taps "Inicia sesión".
  final VoidCallback onSignInTapped;

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  /// Owned here rather than in the form because the screen is what reads the
  /// values when it submits.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Sends the details to the controller.
  ///
  /// The email is trimmed, matching the rule that validates it; the password is
  /// not, because spaces are valid in one.
  void _submit() {
    // The outcome is read from the controller's state, not from this call, so
    // there is nothing to await.
    unawaited(
      ref
          .read(signUpControllerProvider.notifier)
          .signUp(
            SignUpParams(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // A side effect, so ref.listen rather than ref.watch. Fires on the move from
    // loading to success only: the screen's initial "idle" state is also data,
    // and must not navigate.
    ref.listen(signUpControllerProvider, (previous, next) {
      if (previous?.isLoading == true && next is AsyncData<void>) {
        widget.onSignedUp();
      }
    });

    return AuthLayout(
      title: 'Únete a Agora',
      subtitle: 'Descubre, compra y vende piezas únicas en una comunidad de confianza.',
      children: [
        _SignUpForm(
          emailController: _emailController,
          passwordController: _passwordController,
          confirmController: _confirmController,
          onSubmit: _submit,
        ),
        const SizedBox(height: AppSpacing.md),
        const TextDivider('o'),
        const SizedBox(height: AppSpacing.md),
        const GoogleButton('Continuar con Google'),
        const SizedBox(height: AppSpacing.lg),
        AuthSwitchPrompt(
          question: '¿Ya tienes cuenta?',
          actionLabel: 'Inicia sesión',
          onTap: widget.onSignInTapped,
        ),
        const SizedBox(height: AppSpacing.md),
        const LegalNotice(
          opening: 'Al registrarte, aceptas nuestros ',
          termsLabel: 'Términos de servicio',
          connector: ' y la ',
          privacyLabel: 'Política de privacidad',
        ),
      ],
    );
  }
}
