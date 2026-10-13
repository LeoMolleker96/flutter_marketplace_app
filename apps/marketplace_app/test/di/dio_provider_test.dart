import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/di/dio_provider.dart';

void main() {
  group('validateApiBaseUrl', () {
    for (final isDebug in [true, false]) {
      final mode = isDebug ? 'debug' : 'profile/release';

      test('accepts an https address in $mode', () {
        expect(
          validateApiBaseUrl('https://api.example.com', isDebug: isDebug),
          'https://api.example.com',
        );
      });

      for (final url in [
        'http://192.168.1.10:3000',
        'http://api.example.com',
        'ftp://api.example.com',
        'api.example.com',
        'http://',
        'http://[::1',
        '',
      ]) {
        test('refuses "$url" in $mode', () {
          expect(
            () => validateApiBaseUrl(url, isDebug: isDebug),
            throwsStateError,
          );
        });
      }
    }

    for (final url in [
      'http://localhost:3000',
      'http://127.0.0.1:3000',
      'http://10.0.2.2:3000',
    ]) {
      test('accepts the loopback address "$url" in debug', () {
        expect(validateApiBaseUrl(url, isDebug: true), url);
      });

      test('refuses the loopback address "$url" outside debug', () {
        expect(() => validateApiBaseUrl(url, isDebug: false), throwsStateError);
      });
    }

    test('says what was received, what is required and how to fix it', () {
      expect(
        () => validateApiBaseUrl('http://localhost:3000', isDebug: false),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('http://localhost:3000'),
              contains('https'),
              contains('--dart-define=API_BASE_URL=https://'),
            ),
          ),
        ),
      );
    });

    test('names the received address when it is not a usable URL', () {
      expect(
        () => validateApiBaseUrl('ftp://api.example.com', isDebug: true),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('ftp://api.example.com'),
          ),
        ),
      );
    });

    test('suggests a loopback address in debug', () {
      expect(
        () => validateApiBaseUrl('http://api.example.com', isDebug: true),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('http://api.example.com'),
              contains('http://localhost:3000'),
            ),
          ),
        ),
      );
    });
  });

  group('resolveApiBaseUrl', () {
    test('is the local backend when no API_BASE_URL is defined', () {
      expect(resolveApiBaseUrl(), 'http://localhost:3000');
    });
  });
}
