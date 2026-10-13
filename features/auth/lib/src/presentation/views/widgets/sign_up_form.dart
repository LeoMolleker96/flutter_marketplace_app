part of '../sign_up_view.dart';

/// The three fields, the failure message and the "Crear cuenta" button.
class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.onSubmit,
  });

  /// Fired by the button once every rule is satisfied.
  final VoidCallback onSubmit;

  /// Owned by the screen; this form only wires them to their fields.
  final TextEditingController emailController;

  /// Owned by the screen; this form only wires them to their fields.
  final TextEditingController passwordController;

  /// Owned by the screen; this form only wires them to their fields.
  final TextEditingController confirmController;

  /// Why [email] is not acceptable, or null.
  ///
  /// Nothing is said about an empty field: an untouched form must not open
  /// already complaining. The button stays disabled until it is filled in.
  static String? _emailError(String email) {
    if (email.isEmpty || SignUpRules.isValidEmail(email)) return null;
    return 'Introduce un correo válido.';
  }

  static String? _confirmError(String password, String confirmation) {
    if (confirmation.isEmpty ||
        SignUpRules.passwordsMatch(password, confirmation)) {
      return null;
    }
    return 'Las contraseñas no coinciden.';
  }

  @override
  Widget build(BuildContext context) {
    // Each field listens to the controllers its message depends on, so typing in
    // one rebuilds that field and the button, not the whole form.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListenableBuilder(
          listenable: emailController,
          builder: (context, _) => AppTextField(
            label: 'Correo electrónico',
            hintText: 'tu@correo.com',
            icon: Icons.mail_outline,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            errorText: _emailError(emailController.text.trim()),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // The requirements replace a single "too short" message: they say what
        // is still missing, so the field itself carries no error text.
        ListenableBuilder(
          listenable: passwordController,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Contraseña',
                hintText: 'Mínimo ${SignUpRules.minPasswordLength} caracteres',
                icon: Icons.lock_outline,
                controller: passwordController,
                obscurable: true,
                textInputAction: TextInputAction.next,
              ),
              _PasswordRequirements(passwordController.text),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Depends on both: it is the second one that must repeat the first.
        ListenableBuilder(
          listenable: Listenable.merge([passwordController, confirmController]),
          builder: (context, _) => AppTextField(
            label: 'Confirmar contraseña',
            hintText: 'Repite tu contraseña',
            icon: Icons.lock_reset,
            controller: confirmController,
            obscurable: true,
            errorText: _confirmError(
              passwordController.text,
              confirmController.text,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md + AppSpacing.xs),
        const _SignUpError(),
        // Rebuilds only the button as the user types. A TextEditingController
        // is itself a Listenable, so merging them gives the button its own
        // subscription — no setState, and the fields above are left alone.
        ListenableBuilder(
          listenable: Listenable.merge([
            emailController,
            passwordController,
            confirmController,
          ]),
          // The Consumer watches only `isLoading`, so the controller moving
          // between idle, loading and done rebuilds the button and nothing else.
          builder: (context, _) => Consumer(
            builder: (context, ref, _) => AppPrimaryButton(
              label: 'Crear cuenta',
              enabled: SignUpRules.isComplete(
                email: emailController.text,
                password: passwordController.text,
                confirmation: confirmController.text,
              ),
              isLoading: ref.watch(
                signUpControllerProvider.select((state) => state.isLoading),
              ),
              onPressed: onSubmit,
            ),
          ),
        ),
      ],
    );
  }
}
