import 'package:mocktail/mocktail.dart';
import 'package:network/network.dart';

/// The adapter is where a request would leave dio, so replacing it runs the real
/// client, interceptors included. Each package keeps its own copy for the same
/// reason each keeps its own `pumpApp`: sharing one would need a package of its
/// own.
class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

/// An adapter that replies to every request with [status] and [body], without
/// touching the network.
///
/// [body] defaults to the shape the backend agrees to for a successful
/// sign-in, sent as JSON so dio decodes it the way it would for real.
MockHttpClientAdapter stubAdapter({
  required int status,
  String body = '{"token":"fake-token"}',
}) {
  // `any()` needs a stand-in value for the non-nullable argument type.
  registerFallbackValue(RequestOptions());

  final adapter = MockHttpClientAdapter();
  // A reply is built per request: a `ResponseBody` stream can be read once.
  when(() => adapter.fetch(any(), any(), any())).thenAnswer(
    (_) async => ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    ),
  );
  return adapter;
}

/// Every request [adapter] has been asked to send, in order.
///
/// Fails if it was never asked; use `verifyNever` to assert that.
List<RequestOptions> sentRequests(MockHttpClientAdapter adapter) =>
    verify(() => adapter.fetch(captureAny(), any(), any())).captured
        .cast<RequestOptions>();
