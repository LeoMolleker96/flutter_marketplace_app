/// The credentials a user submits to sign in.
///
/// The input of the sign-in operation, kept as one object rather than loose
/// arguments so that adding a field later does not change every signature that
/// passes it along.
///
/// Pure Dart on purpose: it lives in `domain`, which must not import Flutter.
///
/// It holds a password, so it must never be logged. That is also why it does
/// not override `toString`: the default prints only the type name.
class SignInParams {
  /// Creates the credentials for one sign-in attempt.
  const SignInParams({required this.username, required this.password});

  /// What the user typed into the identifier field.
  ///
  /// The form accepts an email address or a username, so despite the name this
  /// may be an email.
  final String username;

  /// The password exactly as typed — never trimmed, since spaces are valid.
  final String password;
}
