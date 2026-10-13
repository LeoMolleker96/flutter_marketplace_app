import 'package:feature_auth/src/domain/params/sign_up_params.dart';
import 'package:feature_auth/src/domain/repositories/auth_repository.dart';
import 'package:feature_auth/src/domain/usecases/sign_up_use_case.dart';
import 'package:feature_auth/src/presentation/providers/auth_repository_provider.dart';
import 'package:feature_auth/src/presentation/providers/sign_up_use_case_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;

  setUpAll(() {
    registerFallbackValue(
      const SignUpParams(email: 'ana@example.com', password: 'Hunter22!'),
    );
  });

  setUp(() {
    repository = _MockAuthRepository();
    when(() => repository.signUp(any())).thenAnswer((_) async {});
  });

  test('builds a SignUpUseCase', () {
    final container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

    expect(container.read(signUpUseCaseProvider), isA<SignUpUseCase>());
  });

  test('runs against whichever repository is provided', () async {
    // The same override that repoints sign-in repoints sign-up.
    final container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    const params = SignUpParams(
      email: 'ana@example.com',
      password: 'Hunter22!',
    );

    await container.read(signUpUseCaseProvider)(params);

    verify(() => repository.signUp(any(that: same(params)))).called(1);
  });
}
