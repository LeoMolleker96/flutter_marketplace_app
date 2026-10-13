import 'package:network/network.dart';

/// What is kept of a failed request once the repository has translated it.
///
/// A `DioException` carries the request that failed — including its body, which
/// for authentication is the user's password — and whatever the server sent
/// back. Holding it as an `AuthFailure.cause` would put a plaintext password
/// inside an object that travels the whole app, where the first error reporter,
/// provider observer or `debugPrint` added later would serialise it.
///
/// So the repository keeps this instead: enough to debug (what kind of failure,
/// which status, which endpoint) and nothing that came from the user.
final class RequestFailureCause {
  /// Creates the cause.
  const RequestFailureCause({
    required this.type,
    required this.path,
    this.statusCode,
  });

  /// Summarises [error], dropping its request and response bodies.
  factory RequestFailureCause.from(DioException error) {
    return RequestFailureCause(
      type: error.type,
      path: error.requestOptions.path,
      statusCode: error.response?.statusCode,
    );
  }

  /// What went wrong at the transport level.
  final DioExceptionType type;

  /// The endpoint, relative to the client's base URL. No query, no body.
  final String path;

  /// The HTTP status, when the server answered at all.
  final int? statusCode;

  @override
  String toString() =>
      'RequestFailureCause(${type.name}, path: $path, status: $statusCode)';
}
