import 'dart:typed_data';

import 'package:network/network.dart';

/// Stands in for the network: answers every request without leaving the process,
/// and records what it was asked.
///
/// The adapter is where a request would leave dio, so swapping it runs the real
/// client, interceptors included. Each package keeps its own copy for the same
/// reason each keeps its own `pumpApp`: sharing one would need a package of its
/// own.
class FakeHttpAdapter implements HttpClientAdapter {
  /// Replies to every request with [status] and [body].
  ///
  /// [body] defaults to the shape the backend agrees to for a successful
  /// sign-in, sent as JSON so dio decodes it the way it would for real.
  FakeHttpAdapter.status(int status, {this._body = '{"token":"test-token"}'})
      : _status = status;

  /// Fails every request the way an unreachable server does.
  FakeHttpAdapter.unreachable()
      : _status = null,
        _body = '';

  final int? _status;
  final String _body;

  /// Every request this adapter has seen, in order.
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    final status = _status;
    if (status == null) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'unreachable in a test',
      );
    }

    return ResponseBody.fromString(
      _body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
