import 'package:flutter/foundation.dart' show visibleForTesting;
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
///
/// **On iOS the Keychain item is `first_unlock_this_device`.** The package's
/// default, `unlocked`, is restored from an encrypted backup onto a new phone,
/// so a session token could travel to a device that is not its owner's. The
/// `_this_device` variants never leave the phone. `first_unlock` (rather than
/// `unlocked`) keeps the item readable after the first unlock since boot, so
/// background work can use the token later. Keychain items also survive an
/// uninstall; clearing them on a fresh install is part of ADR-0007. macOS is not
/// a target of this app, so its options are left at the package default.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  /// Creates the data source.
  ///
  /// [storage] defaults to the real secure store, configured with
  /// [defaultIOSOptions]; it is a parameter so a test can hand in one backed by
  /// memory.
  const AuthLocalDataSourceImpl({
    this._storage = const FlutterSecureStorage(iOptions: defaultIOSOptions),
  });

  final FlutterSecureStorage _storage;

  /// The iOS Keychain options of the default store.
  ///
  /// Public only so a test can pin the accessibility: the storage instance is
  /// private and its options cannot be observed from outside.
  @visibleForTesting
  static const defaultIOSOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  /// The key the token is stored under.
  static const tokenKey = 'auth_token';

  @override
  Future<void> saveToken(String token) {
    return _storage.write(key: tokenKey, value: token);
  }
}
