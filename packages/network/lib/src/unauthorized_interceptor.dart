import 'package:dio/dio.dart';

/// Reports the first `401 Unauthorized` response and ignores every one after it.
///
/// This package does not know what an expired session means for the app — log
/// out, refresh a token, send the user to a sign-in screen. It only notices the
/// 401 and hands the decision to [onUnauthorized], which the app supplies.
///
/// The callback fires **once** for the lifetime of this interceptor. When a
/// session expires, every request in flight tends to fail with 401 at nearly the
/// same time; without the latch, the app would be told to sign the user out a
/// dozen times in a row.
///
/// The response is never swallowed: the original [DioException] always continues
/// to the caller, so each failed request still fails.
class UnauthorizedInterceptor extends Interceptor {
  /// Creates an interceptor that calls [onUnauthorized] on the first 401.
  UnauthorizedInterceptor({required this.onUnauthorized});

  /// Called once, on the first 401 response seen.
  final void Function() onUnauthorized;

  /// Spelled out rather than taken from `dart:io`'s `HttpStatus`, which is not
  /// available on web — and this package has to run there.
  static const _unauthorized = 401;

  bool _hasReported = false;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isUnauthorized = err.response?.statusCode == _unauthorized;

    // Set before calling out, and with no await in between, so concurrent 401s
    // cannot both get past the check.
    if (isUnauthorized && !_hasReported) {
      _hasReported = true;
      onUnauthorized();
    }

    handler.next(err);
  }
}
