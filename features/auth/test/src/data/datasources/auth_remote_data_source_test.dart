import 'package:feature_auth/src/data/datasources/auth_remote_data_source.dart';
import 'package:feature_auth/src/domain/failures/auth_failure.dart';
import 'package:feature_auth/src/domain/params/sign_in_params.dart';
import 'package:feature_auth/src/domain/params/sign_up_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

import '../../../helpers/mock_http_client_adapter.dart';

const _params = SignInParams(email: 'ana@example.com', password: 'hunter22');

void main() {
  (AuthRemoteDataSourceImpl, MockHttpClientAdapter) build(
    int status, {
    String? body,
  }) {
    final adapter = body == null
        ? stubAdapter(status: status)
        : stubAdapter(status: status, body: body);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;

    return (AuthRemoteDataSourceImpl(dio), adapter);
  }

  test('POSTs to the sign-in endpoint under the client base URL', () async {
    final (dataSource, adapter) = build(200);

    await dataSource.signIn(_params);

    final request = sentRequests(adapter).single;
    expect(request.method, 'POST');
    expect(request.uri.toString(), 'https://api.test/auth/sign-in');
  });

  test('sends the credentials as a JSON body', () async {
    final (dataSource, adapter) = build(200);

    await dataSource.signIn(_params);

    expect(sentRequests(adapter).single.data, {
      'email': 'ana@example.com',
      'password': 'hunter22',
    });
  });

  test('does not send a username key', () async {
    final (dataSource, adapter) = build(200);

    await dataSource.signIn(_params);

    expect(sentRequests(adapter).single.data, isNot(contains('username')));
  });

  test('sends the password exactly as typed', () async {
    // Spaces are valid in a password, so nothing may trim it on the way out.
    final (dataSource, adapter) = build(200);

    await dataSource.signIn(
      const SignInParams(email: 'ana', password: '  spaced  '),
    );

    expect(sentRequests(adapter).single.data['password'], '  spaced  ');
  });

  test('completes when the server accepts the credentials', () async {
    final (dataSource, _) = build(200);

    await expectLater(dataSource.signIn(_params), completes);
  });

  test('lets the transport error through untranslated', () async {
    // Interpreting errors is the repository's job; this layer only reports.
    final (dataSource, _) = build(401);

    await expectLater(
      dataSource.signIn(_params),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
    await expectLater(
      dataSource.signIn(_params),
      throwsA(isNot(isA<AuthFailure>())),
    );
  });

  group('signUp', () {
    const signUpParams = SignUpParams(
      email: 'ana@example.com',
      password: 'hunter22',
    );

    test('POSTs to the sign-up endpoint under the client base URL', () async {
      final (dataSource, adapter) = build(201);

      await dataSource.signUp(signUpParams);

      final request = sentRequests(adapter).single;
      expect(request.method, 'POST');
      expect(request.uri.toString(), 'https://api.test/auth/sign-up');
    });

    test('sends the email and password as a JSON body', () async {
      final (dataSource, adapter) = build(201);

      await dataSource.signUp(signUpParams);

      expect(sentRequests(adapter).single.data, {
        'email': 'ana@example.com',
        'password': 'hunter22',
      });
    });

    test('sends the password exactly as typed', () async {
      final (dataSource, adapter) = build(201);

      await dataSource.signUp(
        const SignUpParams(email: 'ana@example.com', password: '  spaced  '),
      );

      expect(sentRequests(adapter).single.data['password'], '  spaced  ');
    });

    test('returns the token the server answers with', () async {
      final (dataSource, _) = build(201, body: '{"token":"abc.def.ghi"}');

      expect(await dataSource.signUp(signUpParams), 'abc.def.ghi');
    });

    test('a response without a token throws a FormatException', () async {
      final (dataSource, _) = build(201, body: '{}');

      await expectLater(
        dataSource.signUp(signUpParams),
        throwsA(isA<FormatException>()),
      );
    });

    test('lets the transport error through untranslated', () async {
      final (dataSource, _) = build(409);

      await expectLater(
        dataSource.signUp(signUpParams),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            409,
          ),
        ),
      );
    });
  });

  group('the token in the response', () {
    test('is returned as a string', () async {
      final (dataSource, _) = build(200, body: '{"token":"abc.def.ghi"}');

      expect(await dataSource.signIn(_params), 'abc.def.ghi');
    });

    test('is returned untouched', () async {
      // A token is opaque: nothing here may trim, decode or reformat it.
      final (dataSource, _) = build(
        200,
        body: '{"token":"  Spaced-Token==  "}',
      );

      expect(await dataSource.signIn(_params), '  Spaced-Token==  ');
    });

    test('may sit next to other fields', () async {
      final (dataSource, _) = build(
        200,
        body: '{"token":"abc","expiresIn":3600,"user":{"id":1}}',
      );

      expect(await dataSource.signIn(_params), 'abc');
    });

    group('when it is missing or unusable', () {
      // The server said yes but broke the agreed shape. Each of these must be a
      // FormatException, not a silent empty string or an opaque cast error.
      final cases = <String, String>{
        'no token field': '{"other":"value"}',
        'an empty token': '{"token":""}',
        'a null token': '{"token":null}',
        'a non-string token': '{"token":123}',
        'an empty object': '{}',
        'a body that is not an object': '["token"]',
        'an empty body': '',
      };

      for (final entry in cases.entries) {
        test('${entry.key} throws a FormatException', () async {
          final (dataSource, _) = build(200, body: entry.value);

          await expectLater(
            dataSource.signIn(_params),
            throwsA(isA<FormatException>()),
          );
        });
      }
    });
  });
}
