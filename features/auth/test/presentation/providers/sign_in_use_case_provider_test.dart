import 'package:feature_auth/src/domain/params/sign_in_params.dart';
import 'package:feature_auth/src/domain/repositories/auth_repository.dart';
import 'package:feature_auth/src/domain/usecases/sign_in_use_case.dart';
import 'package:feature_auth/src/presentation/providers/auth_repository_provider.dart';
import 'package:feature_auth/src/presentation/providers/sign_in_use_case_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class _FakeAuthRepository extends Fake implements AuthRepository {
  final calls = <SignInParams>[];

  @override
  Future<void> signIn(SignInParams params) async => calls.add(params);
}

void main() {
  test('builds a SignInUseCase', () {
    final container = ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ],
    );

    expect(container.read(signInUseCaseProvider), isA<SignInUseCase>());
  });

  test('runs against whichever repository is provided', () async {
    // Overriding the repository is all it takes to repoint the whole chain.
    final repository = _FakeAuthRepository();
    final container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    const params = SignInParams(username: 'ana', password: 'hunter22');

    await container.read(signInUseCaseProvider)(params);

    expect(repository.calls, [same(params)]);
  });
}
