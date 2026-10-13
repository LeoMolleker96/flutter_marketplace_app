import 'dart:typed_data';

import 'package:network/network.dart';

/// Answers every request with a status and body chosen by the test, without
/// touching the network, and records what it was asked.
///
/// The adapter is where a request would leave the process, so swapping it lets a
/// test run the real `Dio` end to end. `network` keeps its own copy for the same
/// reason each package keeps its own `pumpApp`: sharing one would need a package
/// of its own.
class FakeHttpAdapter implements HttpClientAdapter {
  /// Creates an adapter that replies with [status] and [body] to every request.
  ///
  /// [body] defaults to the shape the backend agrees to for a successful
  /// sign-in, and is sent as JSON so dio decodes it the way it would for real.
  FakeHttpAdapter(this.status, {this.body = '{"token":"fake-token"}'});

  /// The status code of every reply.
  final int status;

  /// The body of every reply.
  final String body;

  /// Every request this adapter has seen, in order.
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
