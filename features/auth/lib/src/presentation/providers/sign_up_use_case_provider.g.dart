// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_use_case_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The [SignUpUseCase] the view model runs.
///
/// Built from the same repository as the sign-in use case, so one override of
/// `authRepositoryProvider` points both flows at a different implementation.
///
/// Auto-disposed for the same reason as the sign-in one: the use case holds no
/// state, and the repository underneath is the long-lived piece.

@ProviderFor(signUpUseCase)
final signUpUseCaseProvider = SignUpUseCaseProvider._();

/// The [SignUpUseCase] the view model runs.
///
/// Built from the same repository as the sign-in use case, so one override of
/// `authRepositoryProvider` points both flows at a different implementation.
///
/// Auto-disposed for the same reason as the sign-in one: the use case holds no
/// state, and the repository underneath is the long-lived piece.

final class SignUpUseCaseProvider
    extends $FunctionalProvider<SignUpUseCase, SignUpUseCase, SignUpUseCase>
    with $Provider<SignUpUseCase> {
  /// The [SignUpUseCase] the view model runs.
  ///
  /// Built from the same repository as the sign-in use case, so one override of
  /// `authRepositoryProvider` points both flows at a different implementation.
  ///
  /// Auto-disposed for the same reason as the sign-in one: the use case holds no
  /// state, and the repository underneath is the long-lived piece.
  SignUpUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignUpUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignUpUseCase create(Ref ref) {
    return signUpUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignUpUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignUpUseCase>(value),
    );
  }
}

String _$signUpUseCaseHash() => r'd1bc720af6903bba68758c86d57e65fcc067602e';
