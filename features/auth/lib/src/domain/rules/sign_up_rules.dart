/// One condition a new password must satisfy.
///
/// Each is a case of its own, rather than a single "is this password strong"
/// check, because the screen shows them one by one and turns each green as it is
/// met. An enum keeps that list closed: adding a requirement makes every
/// `switch` over it — the label shown, for one — stop compiling until it is
/// handled.
///
/// Pure Dart: it lives in `domain`, so what counts as a symbol is decided here
/// and not in a widget. The wording shown to the person is the screen's.
enum PasswordRequirement {
  /// At least [SignUpRules.minPasswordLength] characters.
  minLength,

  /// At least one uppercase letter, in any alphabet.
  uppercase,

  /// At least one digit.
  number,

  /// At least one character that is not a letter, a digit or a space.
  symbol;

  static final _uppercase = RegExp(r'\p{Lu}', unicode: true);
  static final _number = RegExp(r'\p{Nd}', unicode: true);

  // A space is not a symbol: "my pass word" must not satisfy the requirement
  // with its separators.
  static final _symbol = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);

  /// Whether [password] satisfies this requirement.
  bool isMetBy(String password) => switch (this) {
    minLength => password.length >= SignUpRules.minPasswordLength,
    uppercase => _uppercase.hasMatch(password),
    number => _number.hasMatch(password),
    symbol => _symbol.hasMatch(password),
  };
}

/// What a sign-up must satisfy before it is worth sending to the server.
///
/// These are business rules, not layout, so they live in `domain` as plain
/// functions: the form reads them to decide what to show, and they can be tested
/// without a widget. The server remains the authority; this only spares the user
/// a round trip for mistakes that are obvious locally.
abstract final class SignUpRules {
  /// The shortest password the app accepts.
  static const minPasswordLength = 8;

  // Deliberately loose: something, an @, something, a dot, something. A
  // stricter pattern rejects real addresses; whether the mailbox exists is for
  // the server to find out.
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Whether [email] looks like an address. Surrounding spaces are ignored.
  static bool isValidEmail(String email) => _email.hasMatch(email.trim());

  /// The requirements [password] does not satisfy yet, in display order.
  static List<PasswordRequirement> unmetRequirements(String password) => [
    for (final requirement in PasswordRequirement.values)
      if (!requirement.isMetBy(password)) requirement,
  ];

  /// Whether [password] satisfies every [PasswordRequirement]. Not trimmed:
  /// spaces count towards the length.
  static bool isValidPassword(String password) =>
      unmetRequirements(password).isEmpty;

  /// Whether [confirmation] repeats [password] exactly.
  static bool passwordsMatch(String password, String confirmation) =>
      password == confirmation;

  /// Whether the three fields together are ready to submit.
  static bool isComplete({
    required String email,
    required String password,
    required String confirmation,
  }) =>
      isValidEmail(email) &&
      isValidPassword(password) &&
      passwordsMatch(password, confirmation);
}
