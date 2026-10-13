part of '../sign_up_view.dart';

/// Tells the user why the last sign-up attempt failed.
///
/// Reads the controller's error and renders nothing when there is none. The
/// message is hidden while a new attempt is in flight, because Riverpod keeps
/// the previous error on a loading state and it would otherwise stay on screen
/// next to the spinner.
class _SignUpError extends ConsumerWidget {
  const _SignUpError();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(
      signUpControllerProvider.select(
        (state) => state.isLoading ? null : state.error,
      ),
    );

    return AuthErrorNotice(error == null ? null : _messageFor(error));
  }

  /// What to tell the person for [error].
  ///
  /// `AuthFailure` is `sealed`, so the `switch` is checked by the compiler.
  /// Anything that is not an `AuthFailure` is a bug or an unexpected error and
  /// gets the generic message rather than a stack trace.
  static String _messageFor(Object error) {
    const generic = 'Something went wrong. Please try again.';

    if (error is! AuthFailure) {
      return generic;
    }

    return switch (error) {
      EmailAlreadyInUseFailure() =>
        'An account with that email already exists.',
      InvalidRequestFailure() || InvalidSignUpFailure() =>
        'Please check the details you entered and try again.',
      ConnectionFailure() =>
        "Can't reach the server. Check your connection and try again.",
      // The account exists; only this device failed to keep the session. Trying
      // to sign up again would be refused, so the person is sent to sign in.
      SessionNotSavedFailure() =>
        "Your account was created, but this device couldn't keep your "
            'session. Please sign in to continue.',
      // Creating an account never checks credentials, so a rejection of them is
      // not a failure this screen can cause.
      InvalidCredentialsFailure() || UnknownAuthFailure() => generic,
    };
  }
}
