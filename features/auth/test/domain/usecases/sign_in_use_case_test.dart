import 'package:feature_auth/src/domain/failures/auth_failure.dart';
import 'package:feature_auth/src/domain/params/sign_in_params.dart';
import 'package:feature_auth/src/domain/repositories/auth_repository.dart';
import 'package:feature_auth/src/domain/usecases/sign_in_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository(this._onSignIn);

  final Future<void> Function(SignInParams params) _onSignIn;

  final calls = <SignInParams>[];

  @override
  Future<void> signIn(SignInParams params) {
    calls.add(params);
    return _onSignIn(params);
  }
}

const _params = SignInParams(username: 'ana@example.com', password: 'hunter22');

void main() {
  test('forwards the credentials to the repository', () async {
    final repository = _FakeAuthRepository((_) async {});

    await SignInUseCase(repository)(_params);

    expect(repository.calls, [same(_params)]);
  });

  test('completes when the repository completes', () async {
    final useCase = SignInUseCase(_FakeAuthRepository((_) async {}));

    await expectLater(useCase(_params), completes);
  });

  test('lets the repository failure reach the caller unchanged', () async {
    const failure = InvalidCredentialsFailure();
    final useCase = SignInUseCase(
      _FakeAuthRepository((_) async => throw failure),
    );

    await expectLater(useCase(_params), throwsA(same(failure)));
  });
}
