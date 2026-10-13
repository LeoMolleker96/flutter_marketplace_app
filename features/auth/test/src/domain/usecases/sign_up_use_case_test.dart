import 'package:feature_auth/src/domain/failures/auth_failure.dart';
import 'package:feature_auth/src/domain/params/sign_up_params.dart';
import 'package:feature_auth/src/domain/repositories/auth_repository.dart';
import 'package:feature_auth/src/domain/usecases/sign_up_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _params = SignUpParams(email: 'ana@example.com', password: 'Hunter22!');

void main() {
  late _MockAuthRepository repository;

  setUpAll(() => registerFallbackValue(_params));

  setUp(() {
    repository = _MockAuthRepository();
    when(() => repository.signUp(any())).thenAnswer((_) async {});
  });

  group('with valid details', () {
    test('forwards them to the repository once', () async {
      await SignUpUseCase(repository)(_params);

      verify(() => repository.signUp(any(that: same(_params)))).called(1);
    });

    test('completes when the repository completes', () async {
      final useCase = SignUpUseCase(repository);

      await expectLater(useCase(_params), completes);
    });

    test('lets the repository failure reach the caller unchanged', () async {
      const failure = EmailAlreadyInUseFailure();
      when(() => repository.signUp(any()))
          .thenAnswer((_) async => throw failure);
      final useCase = SignUpUseCase(repository);

      await expectLater(useCase(_params), throwsA(same(failure)));
    });
  });

  group('with details that break a rule', () {
    Future<void> expectRefused(SignUpParams params) async {
      await expectLater(
        SignUpUseCase(repository)(params),
        throwsA(isA<InvalidSignUpFailure>()),
      );
      verifyNever(() => repository.signUp(any()));
    }

    test('refuses an email that is not an address', () {
      return expectRefused(
        const SignUpParams(email: 'ana', password: 'Hunter22!'),
      );
    });

    test('refuses an empty email', () {
      return expectRefused(
        const SignUpParams(email: '', password: 'Hunter22!'),
      );
    });

    for (final entry in {
      'too short': 'Hu22!',
      'no uppercase letter': 'hunter22!',
      'no number': 'Hunterxx!',
      'no symbol': 'Hunter22x',
      'empty': '',
    }.entries) {
      test('refuses a password that is ${entry.key}', () {
        return expectRefused(
          SignUpParams(email: 'ana@example.com', password: entry.value),
        );
      });
    }
  });
}
