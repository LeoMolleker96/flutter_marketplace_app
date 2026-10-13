import 'package:dio/dio.dart';

import 'unauthorized_interceptor.dart';

/// How long to wait to reach the server before giving up.
const defaultConnectTimeout = Duration(seconds: 15);

/// How long to wait for the server to send, or take, a request or its answer.
const defaultTransferTimeout = Duration(seconds: 30);

/// Creates the [Dio] client the app uses to talk to its backend.
///
/// [baseUrl] is a parameter rather than a constant so the same code can point at
/// a different server per environment (development, staging, production). The
/// caller reads it from its own configuration; this package never decides it.
///
/// [onUnauthorized] runs the first time any request comes back `401`, and only
/// that once — see [UnauthorizedInterceptor]. What to do about an expired
/// session is the app's decision, which is why it is passed in.
///
/// The timeouts exist because dio has none by default: a server that accepts the
/// connection and then says nothing would leave a spinner running forever, and
/// the repositories' timeout failures could never fire. They are parameters so
/// an environment with a slow link can lengthen them.
Dio createDio({
  required String baseUrl,
  required void Function() onUnauthorized,
  Duration connectTimeout = defaultConnectTimeout,
  Duration transferTimeout = defaultTransferTimeout,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      sendTimeout: transferTimeout,
      receiveTimeout: transferTimeout,
    ),
  );

  dio.interceptors.add(UnauthorizedInterceptor(onUnauthorized: onUnauthorized));

  return dio;
}
