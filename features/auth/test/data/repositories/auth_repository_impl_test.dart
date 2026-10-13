import 'package:feature_auth/src/data/datasources/auth_local_data_source.dart';
import 'package:feature_auth/src/data/datasources/auth_remote_data_source.dart';
import 'package:feature_auth/src/data/repositories/auth_repository_impl.dart';
import 'package:feature_auth/src/data/request_failure_cause.dart';
import 'package:feature_auth/src/domain/failures/auth_failure.dart';
import 'package:feature_auth/src/domain/params/sign_in_params.dart';
import 'package:feature_auth/src/domain/params/sign_up_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

/// Records the order things happened in, across both fakes, so a test can say
/// "the token was saved after the server answered" and not only "it was saved".
class _Journal {
  final events = <String>[];
}

/// A remote data source whose behaviour each test supplies.
class _FakeRemoteDataSource implements AuthRemoteDataSource {
  _FakeRemoteDataSource(this._onSignIn, this._journal, {this.onSignUp});

  final Future<String> Function(SignInParams params) _onSignIn;
  final Future<String> Function(SignUpParams params)? onSignUp;
  final _Journal _journal;

  final calls = <SignInParams>[];
  final signUpCalls = <SignUpParams>[];

  @override
  Future<String> signIn(SignInParams params) async {
    calls.add(params);
    _journal.events.add('remote');
    return _onSignIn(params);
  }

  @override
  Future<String> signUp(SignUpParams params) async {
    signUpCalls.add(params);
    _journal.events.add('remote');
    return onSignUp!(params);
  }
}

/// A local data source that keeps what it is given, and can be made to fail.
class _FakeLocalDataSource implements AuthLocalDataSource {
  _FakeLocalDataSource(this._journal, {this.failWith});

  final _Journal _journal;
  final Object? failWith;

  final saved = <String>[];


  @override
  Future<void> saveToken(String token) async {
    _journal.events.add('local');
    final failure = failWith;
    if (failure != null) throw failure;
    saved.add(token);
  }
}

const _params = SignInParams(username: 'ana@example.com', password: 'hunter22');

/// A request that carries what the user typed, as a real one does. The
/// repository must not let any of it travel on inside a failure.
final _request = RequestOptions(
  path: '/auth/sign-in',
  data: {'username': 'ana@example.com', 'password': 'hunter22'},
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
  late _Journal journal;

  setUp(() => journal = _Journal());

  /// A repository whose remote answers with [token], and its fakes.
  (AuthRepositoryImpl, _FakeRemoteDataSource, _FakeLocalDataSource) succeeding({
    String token = 'abc.def.ghi',
    Object? storageFails,
  }) {
    final remote = _FakeRemoteDataSource((_) async => token, journal);
    final local = _FakeLocalDataSource(journal, failWith: storageFails);

    return (AuthRepositoryImpl(remote, local), remote, local);
  }

  /// A repository whose remote throws [error], and its local fake.
  (AuthRepositoryImpl, _FakeLocalDataSource) failingWith(Object error) {
    final remote = _FakeRemoteDataSource((_) async => throw error, journal);
    final local = _FakeLocalDataSource(journal);

    return (AuthRepositoryImpl(remote, local), local);
  }

  group('on success', () {
    test('hands the credentials to the remote data source', () async {
      final (repository, remote, _) = succeeding();

      await repository.signIn(_params);

      expect(remote.calls, [same(_params)]);
    });

    test('gives the token to the local data source to keep', () async {
      final (repository, _, local) = succeeding(token: 'abc.def.ghi');

      await repository.signIn(_params);

      expect(local.saved, ['abc.def.ghi']);
    });

    test('keeps the token untouched', () async {
      final (repository, _, local) = succeeding(token: '  Spaced-Token==  ');

      await repository.signIn(_params);

      expect(local.saved, ['  Spaced-Token==  ']);
    });

    test('saves the token only after the server has answered', () async {
      final (repository, _, _) = succeeding();

      await repository.signIn(_params);

      expect(journal.events, ['remote', 'local']);
    });

    test('completes normally without handing the token to the caller', () async {
      final (repository, _, _) = succeeding();

      await expectLater(repository.signIn(_params), completes);
    });
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
        final (repository, local) = failingWith(entry.value);

        await expectLater(repository.signIn(_params), throwsA(anything));

        expect(local.saved, isEmpty);
        expect(journal.events, ['remote'], reason: 'local was never reached');
      });
    }
  });

  group('translating failures', () {
    test('a 401 becomes InvalidCredentialsFailure', () async {
      final (repository, _) = failingWith(
        _dioError(DioExceptionType.badResponse, status: 401),
      );

      await expectLater(
        repository.signIn(_params),
        throwsA(isA<InvalidCredentialsFailure>()),
      );
    });

    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      test('${type.name} becomes ConnectionFailure', () async {
        final (repository, _) = failingWith(_dioError(type));

        await expectLater(
          repository.signIn(_params),
          throwsA(isA<ConnectionFailure>()),
        );
      });
    }

    for (final status in [400, 403, 404, 500, 503]) {
      test('a $status becomes UnknownAuthFailure', () async {
        final (repository, _) = failingWith(
          _dioError(DioExceptionType.badResponse, status: status),
        );

        await expectLater(
          repository.signIn(_params),
          throwsA(isA<UnknownAuthFailure>()),
        );
      });
    }

    test('a cancelled request becomes UnknownAuthFailure', () async {
      final (repository, _) = failingWith(_dioError(DioExceptionType.cancel));

      await expectLater(
        repository.signIn(_params),
        throwsA(isA<UnknownAuthFailure>()),
      );
    });

    test('a response without a token becomes UnknownAuthFailure', () async {
      // The server accepted the credentials but broke the agreed shape: the
      // backend's fault, so not reported as a bad password.
      const malformed = FormatException('no token');
      final (repository, _) = failingWith(malformed);

      await expectLater(
        repository.signIn(_params),
        throwsA(
          isA<UnknownAuthFailure>().having((f) => f.cause, 'cause', same(malformed)),
        ),
      );
    });

    test('keeps what is useful for debugging as the failure cause', () async {
      final (repository, _) = failingWith(
        _dioError(DioExceptionType.badResponse, status: 401),
      );

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

    test('never carries the request, so the password cannot travel with it',
        () async {
      final (repository, _) = failingWith(
        _dioError(DioExceptionType.badResponse, status: 401),
      );

      Object? cause;
      try {
        await repository.signIn(_params);
      } on AuthFailure catch (failure) {
        cause = failure.cause;
      }

      expect(cause, isNot(isA<DioException>()));
      expect(cause.toString(), isNot(contains('hunter22')));
      expect(cause.toString(), isNot(contains('ana@example.com')));
    });

    test('keeps the original stack trace', () async {
      // The failure is a new type, but the trace should still point at where the
      // error really came from.
      final original = StackTrace.fromString('original-trace');
      final remote = _FakeRemoteDataSource(
        (_) async => Error.throwWithStackTrace(
          _dioError(DioExceptionType.connectionError),
          original,
        ),
        journal,
      );
      final repository = AuthRepositoryImpl(
        remote,
        _FakeLocalDataSource(journal),
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
      final (repository, _, _) = succeeding(storageFails: storageError);

      await expectLater(
        repository.signIn(_params),
        throwsA(
          isA<SessionNotSavedFailure>()
              .having((f) => f.cause, 'cause', same(storageError)),
        ),
      );
    });

    test('is not mistaken for a failure of the request', () async {
      final (repository, _, _) = succeeding(
        storageFails: StateError('keystore unavailable'),
      );

      await expectLater(
        repository.signIn(_params),
        throwsA(isNot(isA<UnknownAuthFailure>())),
      );
    });
  });

  group('signUp', () {
    const signUpParams = SignUpParams(
      email: 'ana@example.com',
      password: 'hunter22',
    );

    /// A repository whose sign-up answers with [outcome], and its fakes.
    ///
    /// [outcome] is either a token to answer with or an error to throw.
    (AuthRepositoryImpl, _FakeRemoteDataSource, _FakeLocalDataSource) build(
      Object outcome, {
      Object? storageFails,
    }) {
      final remote = _FakeRemoteDataSource(
        (_) async => throw UnimplementedError(),
        journal,
        onSignUp: (_) async {
          if (outcome is String) return outcome;
          throw outcome;
        },
      );
      final local = _FakeLocalDataSource(journal, failWith: storageFails);

      return (AuthRepositoryImpl(remote, local), remote, local);
    }

    test('hands the details to the remote data source', () async {
      final (repository, remote, _) = build('abc.def.ghi');

      await repository.signUp(signUpParams);

      expect(remote.signUpCalls, [same(signUpParams)]);
      expect(remote.calls, isEmpty, reason: 'signing in was not involved');
    });

    test('keeps the token, so the new user starts signed in', () async {
      final (repository, _, local) = build('abc.def.ghi');

      await repository.signUp(signUpParams);

      expect(local.saved, ['abc.def.ghi']);
    });

    test('saves the token only after the server has answered', () async {
      final (repository, _, _) = build('abc.def.ghi');

      await repository.signUp(signUpParams);

      expect(journal.events, ['remote', 'local']);
    });

    test('a 409 becomes EmailAlreadyInUseFailure and saves nothing', () async {
      final (repository, _, local) = build(
        _dioError(DioExceptionType.badResponse, status: 409),
      );

      await expectLater(
        repository.signUp(signUpParams),
        throwsA(isA<EmailAlreadyInUseFailure>()),
      );
      expect(local.saved, isEmpty);
    });

    test('no connection becomes ConnectionFailure', () async {
      final (repository, _, local) = build(
        _dioError(DioExceptionType.connectionError),
      );

      await expectLater(
        repository.signUp(signUpParams),
        throwsA(isA<ConnectionFailure>()),
      );
      expect(local.saved, isEmpty);
    });

    test('a 500 becomes UnknownAuthFailure', () async {
      final (repository, _, _) = build(
        _dioError(DioExceptionType.badResponse, status: 500),
      );

      await expectLater(
        repository.signUp(signUpParams),
        throwsA(isA<UnknownAuthFailure>()),
      );
    });

    test('a response without a token becomes UnknownAuthFailure', () async {
      final (repository, _, local) = build(const FormatException('no token'));

      await expectLater(
        repository.signUp(signUpParams),
        throwsA(isA<UnknownAuthFailure>()),
      );
      expect(local.saved, isEmpty);
    });

    test('never carries the request, so the password cannot travel with it',
        () async {
      final (repository, _, _) = build(
        _dioError(DioExceptionType.badResponse, status: 409),
      );

      Object? cause;
      try {
        await repository.signUp(signUpParams);
      } on AuthFailure catch (failure) {
        cause = failure.cause;
      }

      expect(cause, isA<RequestFailureCause>());
      expect(cause.toString(), isNot(contains('hunter22')));
    });

    test(
      'a storage failure after the account is created is SessionNotSavedFailure',
      () async {
        // The account exists on the server. Calling this a generic failure would
        // send the person to try again, and the retry would be refused as an
        // email already taken.
        final storageError = StateError('keystore unavailable');
        final (repository, remote, _) = build('abc', storageFails: storageError);

        await expectLater(
          repository.signUp(signUpParams),
          throwsA(
            isA<SessionNotSavedFailure>()
                .having((f) => f.cause, 'cause', same(storageError)),
          ),
        );
        expect(remote.signUpCalls, hasLength(1));
      },
    );
  });

  test('does not disguise errors that are not from the transport', () async {
    // Only a DioException and a FormatException are translated. A bug elsewhere
    // must stay visible instead of being relabelled as a sign-in failure.
    final bug = StateError('a bug, not a network problem');
    final (repository, _) = failingWith(bug);

    await expectLater(repository.signIn(_params), throwsA(same(bug)));
  });
}
