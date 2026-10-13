import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

import '../helpers/fake_adapter.dart';

void main() {
  late int unauthorizedCalls;

  Dio buildClient(FakeAdapter adapter) {
    final dio = createDio(
      baseUrl: 'https://api.test',
      onUnauthorized: () => unauthorizedCalls++,
    );
    dio.httpClientAdapter = adapter;
    return dio;
  }

  setUp(() => unauthorizedCalls = 0);

  test('calls onUnauthorized when a request returns 401', () async {
    final dio = buildClient(FakeAdapter.always(401));

    await expectLater(dio.get<void>('/me'), throwsA(isA<DioException>()));

    expect(unauthorizedCalls, 1);
  });

  test('calls it only once across later 401s', () async {
    final dio = buildClient(FakeAdapter.always(401));

    for (var i = 0; i < 3; i++) {
      await expectLater(dio.get<void>('/me'), throwsA(isA<DioException>()));
    }

    expect(unauthorizedCalls, 1);
  });

  test('calls it only once when 401s arrive concurrently', () async {
    // The realistic case: a session expires and every request already in flight
    // fails together.
    final dio = buildClient(FakeAdapter.always(401));

    final results = await Future.wait(
      List.generate(
        5,
        (_) => dio
            .get<void>('/me')
            .then<Object?>((_) => null)
            .onError<DioException>((e, _) => e),
      ),
    );

    expect(results, everyElement(isA<DioException>()));
    expect(unauthorizedCalls, 1);
  });

  test('still delivers the 401 to the caller', () async {
    // The interceptor reports; it must not swallow the failure.
    final dio = buildClient(FakeAdapter.always(401));

    await expectLater(
      dio.get<void>('/me'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
  });

  test('ignores other error statuses', () async {
    for (final status in [400, 403, 404, 500]) {
      final dio = buildClient(FakeAdapter.always(status));

      await expectLater(dio.get<void>('/x'), throwsA(isA<DioException>()));
    }

    expect(unauthorizedCalls, 0);
  });

  test('ignores successful responses', () async {
    final dio = buildClient(FakeAdapter.always(200));

    await dio.get<void>('/me');

    expect(unauthorizedCalls, 0);
  });

  test('a non-401 failure does not use up the one report', () async {
    var status = 500;
    final dio = buildClient(FakeAdapter((_) => status));

    await expectLater(dio.get<void>('/x'), throwsA(isA<DioException>()));
    expect(unauthorizedCalls, 0);

    status = 401;
    await expectLater(dio.get<void>('/x'), throwsA(isA<DioException>()));
    expect(unauthorizedCalls, 1);
  });

  test('each client keeps its own latch', () async {
    final first = buildClient(FakeAdapter.always(401));
    final second = buildClient(FakeAdapter.always(401));

    await expectLater(first.get<void>('/me'), throwsA(isA<DioException>()));
    await expectLater(second.get<void>('/me'), throwsA(isA<DioException>()));

    expect(unauthorizedCalls, 2);
  });
}
