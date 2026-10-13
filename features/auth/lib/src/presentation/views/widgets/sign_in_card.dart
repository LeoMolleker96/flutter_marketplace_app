part of '../sign_in_view.dart';

/// The white card holding the credentials form.
class _SignInCard extends StatelessWidget {
  const _SignInCard({
    required this.rememberMe,
    required this.emailController,
    required this.passwordController,
    required this.passwordFocus,
    required this.onSubmit,
    required this.onPasswordSubmitted,
  });

  /// Fired by the Sign In button once the email is valid and the password is
  /// filled in.
  final VoidCallback onSubmit;

  /// Fired by Enter on the password field. The screen decides whether the form
  /// is complete enough to submit.
  final VoidCallback onPasswordSubmitted;

  /// Owned by the screen; Enter on the email moves focus here.
  final FocusNode passwordFocus;

  /// Owned by the screen, listened to only by the checkbox below.
  final ValueNotifier<bool> rememberMe;

  /// Owned by the screen; this card only wires them to their fields.
  final TextEditingController emailController;

  /// Owned by the screen; this card only wires them to their fields.
  final TextEditingController passwordController;

  /// Why [email] is not acceptable, or null.
  ///
  /// Nothing is said about an empty field: an untouched form must not open
  /// already complaining. The button stays disabled until it is filled in.
  /// The longest valid address (RFC 5321). Also bounds what the email regex
  /// runs over on every keystroke.
  static const _maxEmailLength = 254;

  /// Generous for any real password, small enough to stop a pasted megabyte.
  static const _maxPasswordLength = 128;

  static String? _emailError(String email) {
    if (email.isEmpty || EmailRule.isValid(email)) return null;
    return 'Enter a valid email address.';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.03),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Lets a password manager treat the two fields as one login form.
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Rebuilds only this field as the user types, so the message appears
            // and clears without touching the rest of the card.
            ListenableBuilder(
              listenable: emailController,
              builder: (context, _) => AppTextField(
                label: 'Email',
                hintText: 'name@example.com',
                icon: Icons.mail_outline,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.email,
                  AutofillHints.username,
                ],
                maxLength: _maxEmailLength,
                onSubmitted: (_) => passwordFocus.requestFocus(),
                errorText: _emailError(emailController.text.trim()),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Password',
              hintText: '••••••••',
              icon: Icons.lock_outline,
              controller: passwordController,
              obscurable: true,
              focusNode: passwordFocus,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              maxLength: _maxPasswordLength,
              onSubmitted: (_) => onPasswordSubmitted(),
              labelAction: Text(
                'Forgot password?',
                style: context.textStyles.labelSmall?.copyWith(
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md + AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder(
                  valueListenable: rememberMe,
                  builder: (context, value, _) => AppCheckbox(
                    value: value,
                    onChanged: (newValue) => rememberMe.value = newValue,
                    label: 'Remember me',
                  ),
                ),
                const _FaceIdButton(),
              ],
            ),
            const SizedBox(height: AppSpacing.md + AppSpacing.xs),
            const _SignInError(),
            // Rebuilds only the button as the user types. A TextEditingController
            // is itself a Listenable, so merging the two gives the button its own
            // subscription — no setState, and the fields above are left alone.
            ListenableBuilder(
              listenable: Listenable.merge([
                emailController,
                passwordController,
              ]),
              // The Consumer watches only `isLoading`, so the controller moving
              // between idle, loading and done rebuilds the button and nothing
              // else — not the card, not the fields. `select` is what narrows it.
              builder: (context, _) => Consumer(
                builder: (context, ref, _) => AppPrimaryButton(
                  label: 'Sign In',
                  enabled:
                      EmailRule.isValid(emailController.text) &&
                      passwordController.text.isNotEmpty,
                  isLoading: ref.watch(
                    signInControllerProvider.select((state) => state.isLoading),
                  ),
                  onPressed: onSubmit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
