import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

import '../helpers/mock_http_client_adapter.dart';

void main() {
  test('uses the base URL it is given', () {
    final dio = createDio(
      baseUrl: 'https://staging.api.test',
      onUnauthorized: () {},
    );

    expect(dio.options.baseUrl, 'https://staging.api.test');
  });

  test('builds requests against that base URL', () async {
    final adapter = stubAdapterAlways(200);
    final dio = createDio(baseUrl: 'https://api.test', onUnauthorized: () {});
    dio.httpClientAdapter = adapter;

    await dio.get<void>('/listings');

    expect(
      sentRequests(adapter).single.uri.toString(),
      'https://api.test/listings',
    );
  });

  group('timeouts', () {
    test('are set by default, because dio has none', () {
      final dio = createDio(baseUrl: 'https://api.test', onUnauthorized: () {});

      expect(dio.options.connectTimeout, defaultConnectTimeout);
      expect(dio.options.sendTimeout, defaultTransferTimeout);
      expect(dio.options.receiveTimeout, defaultTransferTimeout);
    });

    test('are finite', () {
      final dio = createDio(baseUrl: 'https://api.test', onUnauthorized: () {});

      expect(dio.options.connectTimeout, isNotNull);
      expect(dio.options.receiveTimeout, isNotNull);
      expect(dio.options.connectTimeout, greaterThan(Duration.zero));
      expect(dio.options.receiveTimeout, greaterThan(Duration.zero));
    });

    test('can be lengthened for a slow environment', () {
      final dio = createDio(
        baseUrl: 'https://api.test',
        onUnauthorized: () {},
        connectTimeout: const Duration(seconds: 40),
        transferTimeout: const Duration(seconds: 90),
      );

      expect(dio.options.connectTimeout, const Duration(seconds: 40));
      expect(dio.options.sendTimeout, const Duration(seconds: 90));
      expect(dio.options.receiveTimeout, const Duration(seconds: 90));
    });
  });

  test('two clients can target different environments', () {
    final staging = createDio(
      baseUrl: 'https://staging.api.test',
      onUnauthorized: () {},
    );
    final production = createDio(
      baseUrl: 'https://api.test',
      onUnauthorized: () {},
    );

    expect(staging.options.baseUrl, isNot(production.options.baseUrl));
  });
}
