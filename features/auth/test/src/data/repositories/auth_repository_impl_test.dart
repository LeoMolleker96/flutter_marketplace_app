import 'package:feature_auth/src/data/datasources/auth_local_data_source.dart';
import 'package:feature_auth/src/data/datasources/auth_remote_data_source.dart';
import 'package:feature_auth/src/data/repositories/auth_repository_impl.dart';
import 'package:feature_auth/src/data/request_failure_cause.dart';
import 'package:feature_auth/src/domain/failures/auth_failure.dart';
import 'package:feature_auth/src/domain/params/sign_in_params.dart';
import 'package:feature_auth/src/domain/params/sign_up_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network/network.dart';

class _MockRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class _MockLocalDataSource extends Mock implements AuthLocalDataSource {}

const _params = SignInParams(email: 'ana@example.com', password: 'hunter22');

const _signUpParams = SignUpParams(
  email: 'ana@example.com',
  password: 'hunter22',
);

/// A request that carries what the user typed, as a real one does. The
/// repository must not let any of it travel on inside a failure.
final _request = RequestOptions(
  path: '/auth/sign-in',
  data: {'email': 'ana@example.com', 'password': 'hunter22'},
);

DioException _dioError(DioExceptionType type, {int? status}) {
  return DioException(
    requestOptions: _request,
    type: type,
    response: status == null
        ? null
        : Response<void>(requestOptions: _request, statusCode: status),
  );
}

void main() {
  late _MockRemoteDataSource remote;
  late _MockLocalDataSource local;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_params);
    registerFallbackValue(_signUpParams);
  });

  setUp(() {
    remote = _MockRemoteDataSource();
    local = _MockLocalDataSource();
    repository = AuthRepositoryImpl(remote, local);

    // Keeping a token works unless a test says otherwise.
    when(() => local.saveToken(any())).thenAnswer((_) async {});
  });

  /// Makes the remote sign-in answer with [token].
  void signInAnswers([String token = 'abc.def.ghi']) {
    when(() => remote.signIn(any())).thenAnswer((_) async => token);
  }

  /// Makes the remote sign-in throw [error].
  void signInFails(Object error) {
    when(() => remote.signIn(any())).thenAnswer((_) async => throw error);
  }

  /// Makes keeping the token throw [error].
  void storageFails(Object error) {
    when(() => local.saveToken(any())).thenAnswer((_) async => throw error);
  }

  group('on success', () {
    test('hands the credentials to the remote data source', () async {
      signInAnswers();

      await repository.signIn(_params);

      verify(() => remote.signIn(any(that: same(_params)))).called(1);
    });

    test('gives the token to the local data source to keep', () async {
      signInAnswers('abc.def.ghi');

      await repository.signIn(_params);

      verify(() => local.saveToken('abc.def.ghi')).called(1);
    });

    test('keeps the token untouched', () async {
      signInAnswers('  Spaced-Token==  ');

      await repository.signIn(_params);

      verify(() => local.saveToken('  Spaced-Token==  ')).called(1);
    });

    test('saves the token only after the server has answered', () async {
      signInAnswers();

      await repository.signIn(_params);

      verifyInOrder([() => remote.signIn(any()), () => local.saveToken(any())]);
    });

    test(
      'completes normally without handing the token to the caller',
      () async {
        signInAnswers();

        await expectLater(repository.signIn(_params), completes);
      },
    );
  });

  group('when the remote data source fails', () {
    // No token means nothing to keep: a failed sign-in must leave storage alone.
    final failures = <String, Object>{
      'a 401': _dioError(DioExceptionType.badResponse, status: 401),
      'a 500': _dioError(DioExceptionType.badResponse, status: 500),
      'no connection': _dioError(DioExceptionType.connectionError),
      'a malformed response': const FormatException('no token'),
    };

    for (final entry in failures.entries) {
      test('${entry.key} saves nothing', () async {
        signInFails(entry.value);

        await expectLater(repository.signIn(_params), throwsA(anything));

        verify(() => remote.signIn(any())).called(1);
        verifyNever(() => local.saveToken(any()));
      });
    }
  });

  group('translating failures', () {
    test('a 401 becomes InvalidCredentialsFailure', () async {
      signInFails(_dioError(DioExceptionType.badResponse, status: 401));

      await expectLater(
        repository.signIn(_params),
        throwsA(isA<InvalidCredentialsFailure>()),
      );
    });

    test('a 400 becomes InvalidRequestFailure', () async {
      signInFails(_dioError(DioExceptionType.badResponse, status: 400));

      await expectLater(
        repository.signIn(_params),
        throwsA(isA<InvalidRequestFailure>()),
      );
    });

    test('a 400 keeps a RequestFailureCause, never the DioException', () async {
      signInFails(_dioError(DioExceptionType.badResponse, status: 400));

      Object? cause;
      try {
        await repository.signIn(_params);
      } on AuthFailure catch (failure) {
        cause = failure.cause;
      }

      expect(
        cause,
        isA<RequestFailureCause>().having((c) => c.statusCode, 'status', 400),
      );
      expect(cause, isNot(isA<DioException>()));
      expect(cause.toString(), isNot(contains('hunter22')));
    });

    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      test('${type.name} becomes ConnectionFailure', () async {
        signInFails(_dioError(type));

        await expectLater(
          repository.signIn(_params),
          throwsA(isA<ConnectionFailure>()),
        );
      });
    }

    for (final status in [403, 404, 500, 503]) {
      test('a $status becomes UnknownAuthFailure', () async {
        signInFails(_dioError(DioExceptionType.badResponse, status: status));

        await expectLater(
          repository.signIn(_params),
          throwsA(isA<UnknownAuthFailure>()),
        );
      });
    }

    test('a cancelled request becomes UnknownAuthFailure', () async {
      signInFails(_dioError(DioExceptionType.cancel));

      await expectLater(
        repository.signIn(_params),
        throwsA(isA<UnknownAuthFailure>()),
      );
    });

    test('a response without a token becomes UnknownAuthFailure', () async {
      // The server accepted the credentials but broke the agreed shape: the
      // backend's fault, so not reported as a bad password.
      const malformed = FormatException('no token');
      signInFails(malformed);

      await expectLater(
        repository.signIn(_params),
        throwsA(
          isA<UnknownAuthFailure>().having(
            (f) => f.cause,
            'cause',
            same(malformed),
          ),
        ),
      );
    });

    test('keeps what is useful for debugging as the failure cause', () async {
      signInFails(_dioError(DioExceptionType.badResponse, status: 401));

      await expectLater(
        repository.signIn(_params),
        throwsA(
          isA<AuthFailure>().having(
            (f) => f.cause,
            'cause',
            isA<RequestFailureCause>()
                .having((c) => c.statusCode, 'statusCode', 401)
                .having((c) => c.path, 'path', '/auth/sign-in')
                .having((c) => c.type, 'type', DioExceptionType.badResponse),
          ),
        ),
      );
    });

    test(
      'never carries the request, so the password cannot travel with it',
      () async {
        signInFails(_dioError(DioExceptionType.badResponse, status: 401));

        Object? cause;
        try {
          await repository.signIn(_params);
        } on AuthFailure catch (failure) {
          cause = failure.cause;
        }

        expect(cause, isNot(isA<DioException>()));
        expect(cause.toString(), isNot(contains('hunter22')));
        expect(cause.toString(), isNot(contains('ana@example.com')));
      },
    );

    test('keeps the original stack trace', () async {
      // The failure is a new type, but the trace should still point at where the
      // error really came from.
      final original = StackTrace.fromString('original-trace');
      when(() => remote.signIn(any())).thenAnswer(
        (_) async => Error.throwWithStackTrace(
          _dioError(DioExceptionType.connectionError),
          original,
        ),
      );

      StackTrace? caught;
      try {
        await repository.signIn(_params);
      } on AuthFailure catch (_, stackTrace) {
        caught = stackTrace;
      }

      expect(caught.toString(), contains('original-trace'));
    });
  });

  group('when keeping the token fails', () {
    test('reports SessionNotSavedFailure, keeping the storage error', () async {
      // The server said yes but the device could not keep the token. That is
      // neither a wrong password nor an unknown failure: the person needs to be
      // told the session could not be kept.
      final storageError = StateError('keystore unavailable');
      signInAnswers();
      storageFails(storageError);

      await expectLater(
        repository.signIn(_params),
        throwsA(
          isA<SessionNotSavedFailure>().having(
            (f) => f.cause,
            'cause',
            same(storageError),
          ),
        ),
      );
    });

    test('is not mistaken for a failure of the request', () async {
      signInAnswers();
      storageFails(StateError('keystore unavailable'));

      await expectLater(
        repository.signIn(_params),
        throwsA(isNot(isA<UnknownAuthFailure>())),
      );
    });
  });

  group('signUp', () {
    const signUpParams = _signUpParams;

    /// Makes the remote sign-up answer with [outcome].
    ///
    /// [outcome] is either a token to answer with or an error to throw.
    void signUpOutcome(Object outcome) {
      when(() => remote.signUp(any())).thenAnswer((_) async {
        if (outcome is String) return outcome;
        throw outcome;
      });
    }

    test('hands the details to the remote data source', () async {
      signUpOutcome('abc.def.ghi');

      await repository.signUp(signUpParams);

      verify(() => remote.signUp(any(that: same(signUpParams)))).called(1);
      verifyNever(() => remote.signIn(any()));
    });

    test('keeps the token, so the new user starts signed in', () async {
      signUpOutcome('abc.def.ghi');

      await repository.signUp(signUpParams);

      verify(() => local.saveToken('abc.def.ghi')).called(1);
    });

    test('saves the token only after the server has answered', () async {
      signUpOutcome('abc.def.ghi');

      await repository.signUp(signUpParams);

      verifyInOrder([() => remote.signUp(any()), () => local.saveToken(any())]);
    });

    test('a 409 becomes EmailAlreadyInUseFailure and saves nothing', () async {
      signUpOutcome(_dioError(DioExceptionType.badResponse, status: 409));

      await expectLater(
        repository.signUp(signUpParams),
        throwsA(isA<EmailAlreadyInUseFailure>()),
      );
      verifyNever(() => local.saveToken(any()));
    });

    test('a 400 becomes InvalidRequestFailure and saves nothing', () async {
      signUpOutcome(_dioError(DioExceptionType.badResponse, status: 400));

      await expectLater(
        repository.signUp(signUpParams),
        throwsA(
          isA<InvalidRequestFailure>()
              .having((f) => f.cause, 'cause', isA<RequestFailureCause>())
              .having((f) => f.cause, 'cause', isNot(isA<DioException>())),
        ),
      );
      verifyNever(() => local.saveToken(any()));
    });

    test('no connection becomes ConnectionFailure', () async {
      signUpOutcome(_dioError(DioExceptionType.connectionError));

      await expectLater(
        repository.signUp(signUpParams),
        throwsA(isA<ConnectionFailure>()),
      );
      verifyNever(() => local.saveToken(any()));
    });

    test('a 500 becomes UnknownAuthFailure', () async {
      signUpOutcome(_dioError(DioExceptionType.badResponse, status: 500));

      await expectLater(
        repository.signUp(signUpParams),
        throwsA(isA<UnknownAuthFailure>()),
      );
    });

    test('a response without a token becomes UnknownAuthFailure', () async {
      signUpOutcome(const FormatException('no token'));

      await expectLater(
        repository.signUp(signUpParams),
        throwsA(isA<UnknownAuthFailure>()),
      );
      verifyNever(() => local.saveToken(any()));
    });

    test(
      'never carries the request, so the password cannot travel with it',
      () async {
        signUpOutcome(_dioError(DioExceptionType.badResponse, status: 409));

        Object? cause;
        try {
          await repository.signUp(signUpParams);
        } on AuthFailure catch (failure) {
          cause = failure.cause;
        }

        expect(cause, isA<RequestFailureCause>());
        expect(cause.toString(), isNot(contains('hunter22')));
      },
    );

    test('a storage failure after the account is created is SessionNotSavedFailure', () async {
      // The account exists on the server. Calling this a generic failure would
      // send the person to try again, and the retry would be refused as an
      // email already taken.
      final storageError = StateError('keystore unavailable');
      signUpOutcome('abc');
      storageFails(storageError);

      await expectLater(
        repository.signUp(signUpParams),
        throwsA(
          isA<SessionNotSavedFailure>().having(
            (f) => f.cause,
            'cause',
            same(storageError),
          ),
        ),
      );
      verify(() => remote.signUp(any())).called(1);
    });
  });

  test('does not disguise errors that are not from the transport', () async {
    // Only a DioException and a FormatException are translated. A bug elsewhere
    // must stay visible instead of being relabelled as a sign-in failure.
    final bug = StateError('a bug, not a network problem');
    signInFails(bug);

    await expectLater(repository.signIn(_params), throwsA(same(bug)));
  });
}
