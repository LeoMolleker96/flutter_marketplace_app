import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/di/dio_provider.dart';

void main() {
  group('validateApiBaseUrl in a release build', () {
    test('accepts an https address', () {
      expect(
        validateApiBaseUrl('https://api.example.com', isRelease: true),
        'https://api.example.com',
      );
    });

    for (final url in [
      'http://localhost:3000',
      'http://192.168.1.20:3000',
      'http://staging.example.com',
      'ftp://api.example.com',
      'api.example.com',
      '',
    ]) {
      test('refuses "$url"', () {
        expect(
          () => validateApiBaseUrl(url, isRelease: true),
          throwsStateError,
        );
      });
    }

    test('says what to do about it', () {
      expect(
        () => validateApiBaseUrl('http://localhost:3000', isRelease: true),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(contains('API_BASE_URL'), contains('https')),
          ),
        ),
      );
    });
  });

  group('validateApiBaseUrl outside a release build', () {
    test('lets the local development default through', () {
      expect(
        validateApiBaseUrl('http://localhost:3000', isRelease: false),
        'http://localhost:3000',
      );
    });

    test('lets any address through, because only release is checked', () {
      expect(
        validateApiBaseUrl('http://192.168.1.20:3000', isRelease: false),
        'http://192.168.1.20:3000',
      );
    });
  });
}
