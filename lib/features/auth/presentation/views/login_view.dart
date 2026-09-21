import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_app/core/router/app_router.dart';
import 'package:marketplace_app/core/theme/app_spacing.dart';
import 'package:marketplace_app/core/theme/theme_context_extension.dart';
import 'package:marketplace_app/core/widgets/app_checkbox.dart';
import 'package:marketplace_app/core/widgets/app_primary_button.dart';
import 'package:marketplace_app/core/widgets/app_text.dart';
import 'package:marketplace_app/core/widgets/app_text_field.dart';

// The screen's sections live in their own files but stay part of this library,
// which is what lets them remain private to it. Every import the parts need is
// declared above; a part file cannot have imports of its own.
part 'widgets/brand_mark.dart';
part 'widgets/sign_in_card.dart';
part 'widgets/face_id_button.dart';
part 'widgets/text_divider.dart';
part 'widgets/google_button.dart';
part 'widgets/sign_up_prompt.dart';
part 'widgets/legal_notice.dart';

/// The sign-in screen.
///
/// Presentation only — nothing here signs anyone in yet. The single piece of
/// state it owns is the "Remember me" toggle, which is ephemeral UI state.
///
/// The content column is capped and centred so the form stays readable when the
/// window is a desktop browser rather than a phone (CLAUDE.md section 6).
class LoginView extends StatefulWidget {
  /// Creates the sign-in screen.
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  static const _contentMaxWidth = 440.0;
  static const _subtitleMaxWidth = 280.0;

  /// A [ValueNotifier] rather than `setState` state so that toggling the
  /// checkbox rebuilds only the checkbox, instead of this whole screen and the
  /// text fields inside the card.
  final _rememberMe = ValueNotifier(false);

  /// Owned here rather than in the card because the screen is what will read
  /// the credentials when the sign-in call is wired up.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _rememberMe.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile,
              vertical: AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: _BrandMark()),
                  const SizedBox(height: AppSpacing.md),
                  const AppTitle('Welcome back'),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _subtitleMaxWidth,
                      ),
                      child: const AppSubtitle(
                        'Discover unique finds and connect with trusted sellers',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SignInCard(
                    rememberMe: _rememberMe,
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _TextDivider(),
                  const SizedBox(height: AppSpacing.md),
                  const _GoogleButton(),
                  const SizedBox(height: AppSpacing.lg),
                  const _SignUpPrompt(),
                  const SizedBox(height: AppSpacing.md),
                  const _LegalNotice(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
