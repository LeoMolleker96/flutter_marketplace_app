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
  const SignInParams({required this.email, required this.password});

  /// The email the user signs in with.
  ///
  /// Already trimmed by the caller, unlike [password]: surrounding spaces in an
  /// address are a typing slip, and the server does not trim them itself.
  final String email;

  /// The password exactly as typed — never trimmed, since spaces are valid.
  final String password;
}
