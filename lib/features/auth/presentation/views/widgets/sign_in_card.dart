part of '../login_view.dart';

/// The white card holding the credentials form.
class _SignInCard extends StatelessWidget {
  const _SignInCard({
    required this.rememberMe,
    required this.emailController,
    required this.passwordController,
  });

  /// Owned by the screen, listened to only by the checkbox below.
  final ValueNotifier<bool> rememberMe;

  /// Owned by the screen; this card only wires them to their fields.
  final TextEditingController emailController;

  /// Owned by the screen; this card only wires them to their fields.
  final TextEditingController passwordController;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Email or Username',
            hintText: 'name@example.com',
            icon: Icons.mail_outline,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Password',
            hintText: '••••••••',
            icon: Icons.lock_outline,
            controller: passwordController,
            obscurable: true,
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
          // Rebuilds only the button as the user types. A TextEditingController
          // is itself a Listenable, so merging the two gives the button its own
          // subscription — no setState, and the fields above are left alone.
          ListenableBuilder(
            listenable: Listenable.merge([emailController, passwordController]),
            builder: (context, _) => AppPrimaryButton(
              label: 'Log In',
              enabled: emailController.text.trim().isNotEmpty &&
                  passwordController.text.isNotEmpty,
              // Goes straight through for now — there is nothing to
              // authenticate against yet. `go` rather than `push` so the login
              // screen is not left underneath for the back button.
              onPressed: () => context.go(AppRoutes.listings),
            ),
          ),
        ],
      ),
    );
  }
}
