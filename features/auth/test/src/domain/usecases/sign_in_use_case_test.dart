import 'package:feature_auth/src/domain/failures/auth_failure.dart';
import 'package:feature_auth/src/domain/params/sign_in_params.dart';
import 'package:feature_auth/src/domain/repositories/auth_repository.dart';
import 'package:feature_auth/src/domain/usecases/sign_in_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _params = SignInParams(email: 'ana@example.com', password: 'hunter22');

void main() {
  late _MockAuthRepository repository;

  setUpAll(() => registerFallbackValue(_params));

  setUp(() {
    repository = _MockAuthRepository();
    when(() => repository.signIn(any())).thenAnswer((_) async {});
  });

  test('forwards the credentials to the repository', () async {
    await SignInUseCase(repository)(_params);

    verify(() => repository.signIn(any(that: same(_params)))).called(1);
  });

  test('completes when the repository completes', () async {
    final useCase = SignInUseCase(repository);

    await expectLater(useCase(_params), completes);
  });

  test('lets the repository failure reach the caller unchanged', () async {
    const failure = InvalidCredentialsFailure();
    when(() => repository.signIn(any())).thenAnswer((_) async => throw failure);
    final useCase = SignInUseCase(repository);

    await expectLater(useCase(_params), throwsA(same(failure)));
  });
}
