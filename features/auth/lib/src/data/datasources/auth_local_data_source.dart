import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps authentication data on this device.
///
/// The counterpart of the remote data source, for storage instead of the
/// network. Like it, this is the lowest layer: no decisions, just the operation.
abstract interface class AuthLocalDataSource {
  /// Stores the session [token], replacing any previous one.
  ///
  /// Always stored: the token is what keeps the person signed in, and it is kept
  /// whatever they chose about remembering their password.
  Future<void> saveToken(String token);
}

/// The [AuthLocalDataSource] backed by the platform's secure store.
///
/// `flutter_secure_storage` encrypts what it keeps: the iOS Keychain, and on
/// Android a key held in the Keystore. A token is a credential — whoever has it
/// is the user — so it must not sit in plain shared preferences.
///
/// **Web is the weak case.** There the package keeps the value in `localStorage`,
/// encrypted with an experimental WebCrypto scheme, and it only works over
/// HTTPS or on localhost. Nothing a web page stores for itself is out of reach of
/// a script injected into that same page, so on web this raises the bar rather
/// than closing the door (see docs/adr/0005).
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  /// Creates the data source.
  ///
  /// [storage] defaults to the real secure store; it is a parameter so a test
  /// can hand in one backed by memory.
  const AuthLocalDataSourceImpl({this._storage = const FlutterSecureStorage()});

  final FlutterSecureStorage _storage;

  /// The key the token is stored under.
  static const tokenKey = 'auth_token';

  @override
  Future<void> saveToken(String token) {
    return _storage.write(key: tokenKey, value: token);
  }
}
