import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Answers every request with a status chosen by the test, without touching the
/// network.
///
/// Dio's `HttpClientAdapter` is the seam where a request would leave the
/// process, so replacing it exercises the real interceptor chain end to end.
class FakeAdapter implements HttpClientAdapter {
  /// Creates an adapter that answers with [statusFor] for each request.
  FakeAdapter(this.statusFor);

  /// Replies with [status] to every request.
  FakeAdapter.always(int status) : statusFor = ((_) => status);

  /// Picks the status code for a request.
  final int Function(RequestOptions options) statusFor;

  /// Every request this adapter has seen, in order.
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString('', statusFor(options));
  }

  @override
  void close({bool force = false}) {}
}
