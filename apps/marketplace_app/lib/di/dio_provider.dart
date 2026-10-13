import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:network/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

/// The backend the app talks to.
///
/// Read from a compile-time variable so one codebase can target a different
/// server per environment without a code change:
///
/// ```
/// flutter run --dart-define=API_BASE_URL=https://staging.example.com
/// ```
///
/// The default points at a backend running on this machine, which is where it
/// will be while the app is being built. Proper per-environment configuration
/// arrives with flavors (v0.6) and replaces this.
final _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: Platform.isAndroid || Platform.isIOS ? 'http://10.0.2.2:3000' : 'http://localhost:3000',
);

/// Returns [baseUrl] if it is safe to send credentials to, and throws if not.
///
/// A release build must talk to the backend over HTTPS: usernames, passwords and
/// tokens cross this connection, and over `http://` they would cross it in the
/// clear. Without this check, a build made for a tester with a plain `http://`
/// address — or the development default left in place — would ship that way
/// quietly.
///
/// Debug and profile builds are not checked, because the backend runs on
/// `http://localhost` while the app is being built. [isRelease] is a parameter
/// so a test can exercise both cases; the app passes `kReleaseMode`.
@visibleForTesting
String validateApiBaseUrl(String baseUrl, {required bool isRelease}) {
  if (isRelease && !Uri.parse(baseUrl).isScheme('https')) {
    throw StateError(
      'API_BASE_URL must use https in a release build, but is "$baseUrl". '
      'Pass --dart-define=API_BASE_URL=https://... when building.',
    );
  }

  return baseUrl;
}

/// The HTTP client every feature's data layer uses.
///
/// Declared here, in the app shell, because it is where two packages that must
/// not know each other meet: `network` builds the client but has no idea what an
/// expired session means, and the features need a client but must not build one.
/// The shell is the one place allowed to connect them.
///
/// `onUnauthorized` is deliberately empty for now. Nothing in the app tracks a
/// session yet, so there is nothing to close. When a session exists, signing out
/// goes here — through `ref`, which is why this is a provider.
///
/// `keepAlive`, because a client is shared by the whole app and rebuilding it
/// would also reset the interceptor's one-shot 401 latch.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  return createDio(
    baseUrl: validateApiBaseUrl(_apiBaseUrl, isRelease: kReleaseMode),
    onUnauthorized: () {},
  );
}
