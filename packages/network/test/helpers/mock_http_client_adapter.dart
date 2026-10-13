import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

/// Dio's `HttpClientAdapter` is the seam where a request would leave the
/// process, so replacing it exercises the real interceptor chain end to end.
class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

/// An adapter that answers each request with the status [statusFor] picks,
/// without touching the network.
MockHttpClientAdapter stubAdapter(
  int Function(RequestOptions options) statusFor,
) {
  // `any()` needs a stand-in value for the non-nullable argument type.
  registerFallbackValue(RequestOptions());

  final adapter = MockHttpClientAdapter();
  when(() => adapter.fetch(any(), any(), any())).thenAnswer((invocation) async {
    final options = invocation.positionalArguments.first as RequestOptions;
    return ResponseBody.fromString('', statusFor(options));
  });
  return adapter;
}

/// An adapter that answers every request with [status].
MockHttpClientAdapter stubAdapterAlways(int status) =>
    stubAdapter((_) => status);

/// Every request [adapter] has been asked to send, in order.
///
/// Fails if it was never asked; use `verifyNever` to assert that.
List<RequestOptions> sentRequests(MockHttpClientAdapter adapter) =>
    verify(() => adapter.fetch(captureAny(), any(), any())).captured
        .cast<RequestOptions>();
