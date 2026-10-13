/// What counts as an email address, for every form that asks for one.
///
/// One rule shared by sign-in and sign-up so the two screens cannot disagree.
/// The pattern is the same as the backend's DTO validation on purpose: the
/// client must never accept what the server rejects, or the user would meet a
/// 400 for something the form had just let through.
///
/// Pure Dart: it lives in `domain`, which must not import Flutter.
abstract final class EmailRule {
  // Deliberately loose: something, an @, something, a dot, something. A
  // stricter pattern rejects real addresses; whether the mailbox exists is for
  // the server to find out.
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Whether [email] looks like an address.
  ///
  /// Surrounding spaces are ignored here because the screens trim before
  /// sending; the server, which does not trim, only ever sees the trimmed text.
  static bool isValid(String email) => _email.hasMatch(email.trim());
}
