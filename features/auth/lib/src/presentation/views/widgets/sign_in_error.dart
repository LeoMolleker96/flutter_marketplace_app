part of '../sign_in_view.dart';

/// Tells the user why the last sign-in attempt failed.
///
/// Reads the controller's error and renders nothing when there is none. It
/// watches only what it shows, so it rebuilds when the failure appears or
/// disappears and at no other time.
///
/// The message is hidden while a new attempt is in flight. That has to be done
/// here: Riverpod keeps the previous error on a loading state, so the error is
/// still present during a retry and would otherwise stay on screen next to the
/// spinner.
class _SignInError extends ConsumerWidget {
  const _SignInError();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(
      signInControllerProvider.select(
        (state) => state.isLoading ? null : state.error,
      ),
    );

    return AuthErrorNotice(error == null ? null : _messageFor(error));
  }

  /// What to tell the person for [error].
  ///
  /// The failures are `sealed`, so the `switch` is checked by the compiler:
  /// adding a case to `AuthFailure` makes this stop compiling until the new
  /// message is written here. Anything that is not an `AuthFailure` is a bug or
  /// an unexpected error, and gets the generic message rather than a stack
  /// trace.
  static String _messageFor(Object error) {
    const generic = 'Something went wrong. Please try again.';

    if (error is! AuthFailure) {
      return generic;
    }

    return switch (error) {
      InvalidCredentialsFailure() => 'Incorrect username or password.',
      ConnectionFailure() =>
        "Can't reach the server. Check your connection and try again.",
      SessionNotSavedFailure() =>
        "You're signed in, but this device couldn't keep your session. "
            'Please try again.',
      // Signing in never creates an account, so a clash of emails is not a
      // failure this screen can cause.
      EmailAlreadyInUseFailure() || UnknownAuthFailure() => generic,
    };
  }
}
