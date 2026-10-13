// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_use_case_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The [SignInUseCase] the view model runs.
///
/// Built from the repository, so overriding `authRepositoryProvider` is all it
/// takes to point the whole chain — controller, use case, repository — at a
/// different implementation, in the app or in a test.
///
/// Auto-disposed: the use case holds no state of its own, so there is nothing
/// worth keeping alive. The repository underneath is the long-lived piece.

@ProviderFor(signInUseCase)
final signInUseCaseProvider = SignInUseCaseProvider._();

/// The [SignInUseCase] the view model runs.
///
/// Built from the repository, so overriding `authRepositoryProvider` is all it
/// takes to point the whole chain — controller, use case, repository — at a
/// different implementation, in the app or in a test.
///
/// Auto-disposed: the use case holds no state of its own, so there is nothing
/// worth keeping alive. The repository underneath is the long-lived piece.

final class SignInUseCaseProvider
    extends $FunctionalProvider<SignInUseCase, SignInUseCase, SignInUseCase>
    with $Provider<SignInUseCase> {
  /// The [SignInUseCase] the view model runs.
  ///
  /// Built from the repository, so overriding `authRepositoryProvider` is all it
  /// takes to point the whole chain — controller, use case, repository — at a
  /// different implementation, in the app or in a test.
  ///
  /// Auto-disposed: the use case holds no state of its own, so there is nothing
  /// worth keeping alive. The repository underneath is the long-lived piece.
  SignInUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignInUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignInUseCase create(Ref ref) {
    return signInUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInUseCase>(value),
    );
  }
}

String _$signInUseCaseHash() => r'c6ac204cf3d8d14a9b5a14afd07c9c51c304a5c8';
