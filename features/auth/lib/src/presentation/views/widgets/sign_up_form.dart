part of '../sign_up_view.dart';

/// The three fields, the failure message and the "Sign Up" button.
class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.passwordFocus,
    required this.confirmFocus,
    required this.onSubmit,
    required this.onConfirmSubmitted,
  });

  /// Fired by the button once every rule is satisfied.
  final VoidCallback onSubmit;

  /// Fired by Enter on the confirmation. The screen decides whether the form
  /// is complete enough to submit.
  final VoidCallback onConfirmSubmitted;

  /// Owned by the screen; Enter on the email moves focus here.
  final FocusNode passwordFocus;

  /// Owned by the screen; Enter on the password moves focus here.
  final FocusNode confirmFocus;

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
  /// The longest valid address (RFC 5321). Also bounds what the email regex
  /// runs over on every keystroke.
  static const _maxEmailLength = 254;

  /// Generous for any real password, small enough to stop a pasted megabyte.
  static const _maxPasswordLength = 128;

  static String? _emailError(String email) {
    if (email.isEmpty || SignUpRules.isValidEmail(email)) return null;
    return 'Enter a valid email address.';
  }

  static String? _confirmError(String password, String confirmation) {
    if (confirmation.isEmpty ||
        SignUpRules.passwordsMatch(password, confirmation)) {
      return null;
    }
    return 'Passwords do not match.';
  }

  @override
  Widget build(BuildContext context) {
    // Each field listens to the controllers its message depends on, so typing in
    // one rebuilds that field and the button, not the whole form.
    // Lets a password manager treat the fields as one registration form.
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListenableBuilder(
            listenable: emailController,
            builder: (context, _) => AppTextField(
              label: 'Email',
              hintText: 'name@example.com',
              icon: Icons.mail_outline,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              maxLength: _maxEmailLength,
              onSubmitted: (_) => passwordFocus.requestFocus(),
              errorText: _emailError(emailController.text.trim()),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // The requirements replace a single "too short" message: they say what
          // is still missing, so the field itself carries no error text.
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Outside the builder below: nothing it receives depends on the
              // password text, so typing must not rebuild it.
              AppTextField(
                label: 'Password',
                hintText:
                    'At least ${SignUpRules.minPasswordLength} characters',
                icon: Icons.lock_outline,
                controller: passwordController,
                obscurable: true,
                focusNode: passwordFocus,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                maxLength: _maxPasswordLength,
                onSubmitted: (_) => confirmFocus.requestFocus(),
              ),
              // Scoped to the checklist, the only reader of the text: like
              // Bloc's `buildWhen` / `BlocSelector`, rebuild just what reads
              // the value that changes.
              ListenableBuilder(
                listenable: passwordController,
                builder: (context, _) =>
                    _PasswordRequirements(passwordController.text),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Depends on both: it is the second one that must repeat the first.
          ListenableBuilder(
            listenable: Listenable.merge([
              passwordController,
              confirmController,
            ]),
            builder: (context, _) => AppTextField(
              label: 'Confirm password',
              hintText: 'Repeat your password',
              icon: Icons.lock_reset,
              controller: confirmController,
              obscurable: true,
              focusNode: confirmFocus,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              maxLength: _maxPasswordLength,
              onSubmitted: (_) => onConfirmSubmitted(),
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
                label: 'Sign Up',
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
      ),
    );
  }
}
