import 'dart:async';

import 'package:feature_auth/src/domain/params/sign_in_params.dart';
import 'package:feature_auth/src/domain/repositories/auth_repository.dart';
import 'package:feature_auth/src/presentation/providers/auth_repository_provider.dart';
import 'package:feature_auth/src/presentation/view_models/sign_in_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// A repository whose behaviour each test supplies, and which remembers what it
/// was asked to do.
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
  /// A container wired to [repository], with the controller kept alive.
  ///
  /// The controller is auto-disposed, so without a listener it would be torn
  /// down between the calls a test makes. The listener also records every state
  /// it moves through.
  (ProviderContainer, List<AsyncValue<void>>) setUpContainer(
    AuthRepository repository,
  ) {
    final container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    final states = <AsyncValue<void>>[];

    container.listen(
      signInControllerProvider,
      (_, next) => states.add(next),
      fireImmediately: true,
    );

    return (container, states);
  }

  test('starts idle, with a value and no work in flight', () {
    final (container, _) = setUpContainer(
      _FakeAuthRepository((_) async {}),
    );

    final state = container.read(signInControllerProvider);

    expect(state, isA<AsyncData<void>>());
    expect(state.isLoading, isFalse);
  });

  test('moves from idle to loading to data on success', () async {
    final (container, states) = setUpContainer(
      _FakeAuthRepository((_) async {}),
    );

    await container.read(signInControllerProvider.notifier).signIn(_params);

    expect(states, [
      isA<AsyncData<void>>(),
      isA<AsyncLoading<void>>(),
      isA<AsyncData<void>>(),
    ]);
  });

  test('passes the credentials to the repository untouched', () async {
    final repository = _FakeAuthRepository((_) async {});
    final (container, _) = setUpContainer(repository);

    await container.read(signInControllerProvider.notifier).signIn(_params);

    expect(repository.calls, hasLength(1));
    expect(repository.calls.single.username, 'ana@example.com');
    expect(repository.calls.single.password, 'hunter22');
  });

  test('is loading while the request is in flight', () async {
    final pending = Completer<void>();
    final (container, _) = setUpContainer(
      _FakeAuthRepository((_) => pending.future),
    );

    final attempt =
        container.read(signInControllerProvider.notifier).signIn(_params);

    expect(container.read(signInControllerProvider).isLoading, isTrue);

    pending.complete();
    await attempt;

    expect(container.read(signInControllerProvider).isLoading, isFalse);
  });

  test('keeps a failure in the state instead of throwing it', () async {
    final failure = StateError('wrong password');
    final (container, states) = setUpContainer(
      _FakeAuthRepository((_) async => throw failure),
    );

    // Completes normally: the view reads the error from the state.
    await container.read(signInControllerProvider.notifier).signIn(_params);

    final state = container.read(signInControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, same(failure));
    expect(states.last, isA<AsyncError<void>>());
  });

  test('can try again after a failure', () async {
    var attempts = 0;
    final (container, _) = setUpContainer(
      _FakeAuthRepository((_) async {
        attempts++;
        if (attempts == 1) throw StateError('first attempt fails');
      }),
    );
    final controller = container.read(signInControllerProvider.notifier);

    await controller.signIn(_params);
    expect(container.read(signInControllerProvider).hasError, isTrue);

    await controller.signIn(_params);
    expect(container.read(signInControllerProvider).hasError, isFalse);
    expect(attempts, 2);
  });

  test('does not write to its state after being disposed', () async {
    // The screen can disappear while the request is still in flight. Writing to
    // a disposed notifier would throw, so the controller must check first.
    final pending = Completer<void>();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository((_) => pending.future),
        ),
      ],
    );
    final subscription = container.listen(signInControllerProvider, (_, _) {});

    final attempt =
        container.read(signInControllerProvider.notifier).signIn(_params);

    subscription.close();
    container.dispose();
    pending.complete();

    await expectLater(attempt, completes);
  });
}
