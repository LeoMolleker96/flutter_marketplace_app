import 'package:feature_auth/src/domain/failures/auth_failure.dart';
import 'package:feature_auth/src/domain/params/sign_up_params.dart';
import 'package:feature_auth/src/domain/repositories/auth_repository.dart';
import 'package:feature_auth/src/domain/usecases/sign_up_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository(this._onSignUp);

  final Future<void> Function(SignUpParams params) _onSignUp;

  final calls = <SignUpParams>[];

  @override
  Future<void> signUp(SignUpParams params) {
    calls.add(params);
    return _onSignUp(params);
  }
}

const _params = SignUpParams(email: 'ana@example.com', password: 'hunter22');

void main() {
  test('forwards the details to the repository', () async {
    final repository = _FakeAuthRepository((_) async {});

    await SignUpUseCase(repository)(_params);

    expect(repository.calls, [same(_params)]);
  });

  test('completes when the repository completes', () async {
    final useCase = SignUpUseCase(_FakeAuthRepository((_) async {}));

    await expectLater(useCase(_params), completes);
  });

  test('lets the repository failure reach the caller unchanged', () async {
    const failure = EmailAlreadyInUseFailure();
    final useCase = SignUpUseCase(
      _FakeAuthRepository((_) async => throw failure),
    );

    await expectLater(useCase(_params), throwsA(same(failure)));
  });
}
