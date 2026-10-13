/// What a user submits to create an account.
///
/// The input of the sign-up operation, kept as one object for the same reason as
/// `SignInParams`: adding a field later (a display name, say) must not change
/// every signature that passes it along.
///
/// It is separate from `SignInParams` rather than reused because the two are
/// different questions: sign-in checks who someone is, sign-up creates an
/// account. Both are keyed by an email address today, but they are free to
/// diverge.
///
/// Pure Dart on purpose: it lives in `domain`, which must not import Flutter.
///
/// It holds a password, so it must never be logged. That is also why it does
/// not override `toString`: the default prints only the type name.
class SignUpParams {
  /// Creates the details for one sign-up attempt.
  const SignUpParams({required this.email, required this.password});

  /// The address the account is created for.
  final String email;

  /// The password exactly as typed — never trimmed, since spaces are valid.
  final String password;
}
