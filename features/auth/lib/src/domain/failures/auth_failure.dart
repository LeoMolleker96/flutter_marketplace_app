/// Why an authentication attempt failed, in terms the app understands.
///
/// The repository catches raw infrastructure errors (a `DioException`, a
/// timeout) and throws one of these instead, so nothing above the data layer
/// ever has to know which HTTP library is underneath.
///
/// `sealed` so an exhaustive `switch` over a failure is checked by the compiler:
/// adding a case turns every incomplete handler into an analyzer error rather
/// than a surprise at runtime.
///
/// Carries no user-facing text. What to tell the person is a presentation
/// decision (and will need translating); [cause] is for logs only.
sealed class AuthFailure implements Exception {
  /// Creates a failure, optionally keeping the original error as [cause].
  const AuthFailure({this.cause});

  /// The error that triggered this failure. For debugging, never for display.
  final Object? cause;

  @override
  String toString() => '$runtimeType';
}

/// The server rejected the email or password.
final class InvalidCredentialsFailure extends AuthFailure {
  /// Creates the failure.
  const InvalidCredentialsFailure({super.cause});
}

/// The server rejected the request as malformed (a 400).
///
/// The client validates the same rules before sending, so this should be rare:
/// when it happens it means the two sides' rules disagree, which is a bug to fix
/// rather than something the person can act on.
final class InvalidRequestFailure extends AuthFailure {
  /// Creates the failure.
  const InvalidRequestFailure({super.cause});
}

/// The sign-up input broke a business rule from `SignUpRules`.
///
/// Raised by the use case before any request is made, so the server is never
/// called with input the app already knows is invalid. Unlike
/// [InvalidRequestFailure], which is the server disagreeing, this is the app
/// refusing on its own; it needs no cause because nothing failed underneath.
final class InvalidSignUpFailure extends AuthFailure {
  /// Creates the failure.
  const InvalidSignUpFailure();
}

/// An account already exists for the email address being signed up.
///
/// Its own case because it is the one sign-up failure the person can act on: use
/// a different address, or sign in instead.
final class EmailAlreadyInUseFailure extends AuthFailure {
  /// Creates the failure.
  const EmailAlreadyInUseFailure({super.cause});
}

/// The server could not be reached: no connection, or it took too long.
///
/// Distinct because it is the one failure where trying again later is a
/// sensible thing to offer.
final class ConnectionFailure extends AuthFailure {
  /// Creates the failure.
  const ConnectionFailure({super.cause});
}

/// The server said yes, but this device could not keep the session.
///
/// Distinct from [UnknownAuthFailure] because the situation is not the same for
/// the person. The server has already done its part — after a sign-up the
/// account exists — so a generic "something went wrong" would be a lie, and
/// retrying the same action would be refused (an email taken, in the sign-up
/// case). What helps is being told to sign in.
final class SessionNotSavedFailure extends AuthFailure {
  /// Creates the failure.
  const SessionNotSavedFailure({super.cause});
}

/// Anything else — a server error, an unreadable response.
///
/// If this shows up often in logs, a more specific case is missing.
final class UnknownAuthFailure extends AuthFailure {
  /// Creates the failure.
  const UnknownAuthFailure({super.cause});
}
