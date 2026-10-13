import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/params/sign_in_params.dart';
import '../../domain/rules/email_rule.dart';
import '../view_models/sign_in_controller.dart';
import '../widgets/auth_error_notice.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/google_button.dart';
import '../widgets/legal_notice.dart';
import '../widgets/text_divider.dart';

// The sections only this screen uses live in their own files but stay part of
// this library, which is what lets them remain private to it. Every import the
// parts need is declared above; a part file cannot have imports of its own.
// What the authentication screens share is in `../widgets/` instead.
part 'widgets/sign_in_card.dart';
part 'widgets/sign_in_error.dart';
part 'widgets/face_id_button.dart';

/// The sign-in screen.
///
/// Collects the credentials and hands them to `SignInController`; it does not
/// sign anyone in itself. The state it owns is ephemeral UI state — the
/// "Remember me" toggle and the text being typed — which nothing outside this
/// screen reads.
///
/// Knows nothing about where a signed-in user goes next, or where "Sign up"
/// leads: that is decided by the app shell, which hands in [onSignedIn] and
/// [onSignUpTapped]. This is what keeps the auth feature from depending on any
/// other feature or on the router.
class SignInView extends ConsumerStatefulWidget {
  /// Creates the sign-in screen.
  const SignInView({
    required this.onSignedIn,
    required this.onSignUpTapped,
    super.key,
  });

  /// Called once, when a sign-in attempt succeeds.
  ///
  /// Not called when the attempt fails or while it is still in flight.
  final VoidCallback onSignedIn;

  /// Called when the user taps "Sign up".
  final VoidCallback onSignUpTapped;

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  /// A [ValueNotifier] rather than `setState` state so that toggling the
  /// checkbox rebuilds only the checkbox, instead of this whole screen and the
  /// text fields inside the card.
  final _rememberMe = ValueNotifier(false);

  /// Owned here rather than in the card because the screen is what reads the
  /// credentials when it submits.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Owned with the controllers so Enter on the email can move to the password.
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _rememberMe.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Enter on the password field: submits only if the button would let it.
  ///
  /// The same guard as the button's `enabled` and `isLoading`, because Enter
  /// is a second way to press it and must not bypass what it refuses.
  void _submitFromKeyboard() {
    final canSubmit =
        EmailRule.isValid(_emailController.text) &&
        _passwordController.text.isNotEmpty;
    if (!canSubmit || ref.read(signInControllerProvider).isLoading) return;
    _submit();
  }

  /// Sends the credentials to the controller.
  ///
  /// The email is trimmed, matching the rule that enables the button; the
  /// password is not, because spaces are valid in one.
  void _submit() {
    // The outcome is read from the controller's state, not from this call, so
    // there is nothing to await.
    unawaited(
      ref
          .read(signInControllerProvider.notifier)
          .signIn(
            SignInParams(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // A side effect, so ref.listen rather than ref.watch (the BlocListener to
    // watch's BlocBuilder). Fires on the move from loading to success only: the
    // screen's initial "idle" state is also data, and must not navigate.
    ref.listen(signInControllerProvider, (previous, next) {
      if (previous?.isLoading == true && next is AsyncData<void>) {
        widget.onSignedIn();
      }
    });

    return AuthLayout(
      title: 'Welcome back',
      subtitle: 'Discover unique finds and connect with trusted sellers',
      children: [
        _SignInCard(
          rememberMe: _rememberMe,
          emailController: _emailController,
          passwordController: _passwordController,
          passwordFocus: _passwordFocus,
          onSubmit: _submit,
          onPasswordSubmitted: _submitFromKeyboard,
        ),
        const SizedBox(height: AppSpacing.md),
        const TextDivider('Or Continue With'),
        const SizedBox(height: AppSpacing.md),
        const GoogleButton('Continue with Google'),
        const SizedBox(height: AppSpacing.lg),
        AuthSwitchPrompt(
          question: "Don't have an account?",
          actionLabel: 'Sign up',
          onTap: widget.onSignUpTapped,
        ),
        const SizedBox(height: AppSpacing.md),
        const LegalNotice(
          opening: "By continuing, you agree to Agora's ",
          termsLabel: 'Terms of Service',
          connector: ' & ',
          privacyLabel: 'Privacy Policy',
        ),
      ],
    );
  }
}
