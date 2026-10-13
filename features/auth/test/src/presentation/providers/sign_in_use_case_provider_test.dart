import 'package:feature_auth/src/domain/params/sign_in_params.dart';
import 'package:feature_auth/src/domain/repositories/auth_repository.dart';
import 'package:feature_auth/src/domain/usecases/sign_in_use_case.dart';
import 'package:feature_auth/src/presentation/providers/auth_repository_provider.dart';
import 'package:feature_auth/src/presentation/providers/sign_in_use_case_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;

  setUpAll(() {
    registerFallbackValue(
      const SignInParams(email: 'ana', password: 'hunter22'),
    );
  });

  setUp(() {
    repository = _MockAuthRepository();
    when(() => repository.signIn(any())).thenAnswer((_) async {});
  });

  test('builds a SignInUseCase', () {
    final container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

    expect(container.read(signInUseCaseProvider), isA<SignInUseCase>());
  });

  test('runs against whichever repository is provided', () async {
    // Overriding the repository is all it takes to repoint the whole chain.
    final container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    const params = SignInParams(email: 'ana', password: 'hunter22');

    await container.read(signInUseCaseProvider)(params);

    verify(() => repository.signIn(any(that: same(params)))).called(1);
  });
}
