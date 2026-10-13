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
/// It must be `const`: the compiler substitutes a `--dart-define` value only
/// where `String.fromEnvironment` is read in a constant expression. Web and AOT
/// builds (mobile release/profile) have no runtime environment to ask, so a
/// non-const read compiles to an error on web and silently ignores the define
/// under AOT. That is also why the default cannot depend on the platform
/// (`Platform.isAndroid` does not even exist on web): it is a single constant.
///
/// The default points at a backend running on this machine, which is where it
/// will be while the app is being built. It works on web, desktop and the iOS
/// simulator. The Android emulator cannot reach the host through `localhost`
/// (that is the emulator itself), so run it with
/// `--dart-define=API_BASE_URL=http://10.0.2.2:3000`, where `10.0.2.2` is the
/// emulator's alias for the host machine. A physical device needs the
/// computer's LAN address over https, or a debug-only loopback tunnel. Proper
/// per-environment configuration arrives with flavors (v0.6) and replaces this.
const _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

/// Hosts a debug build may reach over plain `http`: this machine, and the
/// Android emulator's alias for it. Traffic to them never leaves the computer.
const _debugHttpHosts = {'localhost', '127.0.0.1', '10.0.2.2'};

/// The validated backend address for this build.
///
/// Reads the compile-time `API_BASE_URL` and checks it against the current
/// build mode (`kDebugMode`). It is public so `main` can call it before
/// `runApp`: a misconfigured build then fails at startup instead of on the
/// first sign-in, when a user is already waiting. `dioProvider` uses the same
/// function, so the address that was checked is the one that is used.
String resolveApiBaseUrl() {
  return validateApiBaseUrl(_apiBaseUrl, isDebug: kDebugMode);
}

/// Returns [baseUrl] if it is safe to send credentials to, and throws if not.
///
/// Emails, passwords and tokens cross this connection, so `https` is
/// accepted in every build mode. Plain `http` is accepted only in a debug build
/// and only for `localhost`, `127.0.0.1` or `10.0.2.2`, where the traffic never
/// leaves the machine. Everything else is refused, so profile and release builds
/// require `https`: a build made for a tester with a plain `http://` address, or
/// with the development default left in place, would otherwise ship sending
/// credentials in the clear.
///
/// An address that cannot be parsed, has no host, or uses a scheme other than
/// `http`/`https` is refused too. [isDebug] is a parameter so a test can
/// exercise both cases; the app passes `kDebugMode`.
@visibleForTesting
String validateApiBaseUrl(String baseUrl, {required bool isDebug}) {
  final uri = Uri.tryParse(baseUrl);
  final isHttp = uri != null && uri.isScheme('http');
  final isHttps = uri != null && uri.isScheme('https');

  if (uri == null || uri.host.isEmpty || !(isHttp || isHttps)) {
    throw StateError(
      'API_BASE_URL is "$baseUrl", which is not a valid http(s) address with a '
      'host. Pass --dart-define=API_BASE_URL=https://... when building.',
    );
  }

  if (isHttps) return baseUrl;

  if (isDebug && _debugHttpHosts.contains(uri.host)) return baseUrl;

  final required = isDebug
      ? 'https, or http to one of ${_debugHttpHosts.join(', ')}'
      : 'https in profile and release builds';
  throw StateError(
    'API_BASE_URL is "$baseUrl", but $required is required. '
    'Pass --dart-define=API_BASE_URL=https://... when building'
    '${isDebug ? ', or a loopback http URL such as http://localhost:3000' : ''}.',
  );
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
    baseUrl: resolveApiBaseUrl(),
    onUnauthorized: () {},
  );
}
