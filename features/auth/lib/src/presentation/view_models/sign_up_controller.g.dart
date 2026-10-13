// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks one sign-up attempt: idle, in flight, succeeded, or failed.
///
/// The twin of `SignInController`, an `AsyncNotifier<void>` for the same
/// reason: it models an **action**, so `build` is empty and the `AsyncValue`
/// around the `void` is the whole state. Two controllers rather than one because
/// the two screens are open at different times and must not show each other's
/// progress or errors.
///
/// Auto-disposed: it belongs to the sign-up screen and resets when the screen
/// goes away.

@ProviderFor(SignUpController)
final signUpControllerProvider = SignUpControllerProvider._();

/// Tracks one sign-up attempt: idle, in flight, succeeded, or failed.
///
/// The twin of `SignInController`, an `AsyncNotifier<void>` for the same
/// reason: it models an **action**, so `build` is empty and the `AsyncValue`
/// around the `void` is the whole state. Two controllers rather than one because
/// the two screens are open at different times and must not show each other's
/// progress or errors.
///
/// Auto-disposed: it belongs to the sign-up screen and resets when the screen
/// goes away.
final class SignUpControllerProvider
    extends $AsyncNotifierProvider<SignUpController, void> {
  /// Tracks one sign-up attempt: idle, in flight, succeeded, or failed.
  ///
  /// The twin of `SignInController`, an `AsyncNotifier<void>` for the same
  /// reason: it models an **action**, so `build` is empty and the `AsyncValue`
  /// around the `void` is the whole state. Two controllers rather than one because
  /// the two screens are open at different times and must not show each other's
  /// progress or errors.
  ///
  /// Auto-disposed: it belongs to the sign-up screen and resets when the screen
  /// goes away.
  SignUpControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpControllerHash();

  @$internal
  @override
  SignUpController create() => SignUpController();
}

String _$signUpControllerHash() => r'4d2af00881d523fd537b3a1817c6e8d41e8c555a';

/// Tracks one sign-up attempt: idle, in flight, succeeded, or failed.
///
/// The twin of `SignInController`, an `AsyncNotifier<void>` for the same
/// reason: it models an **action**, so `build` is empty and the `AsyncValue`
/// around the `void` is the whole state. Two controllers rather than one because
/// the two screens are open at different times and must not show each other's
/// progress or errors.
///
/// Auto-disposed: it belongs to the sign-up screen and resets when the screen
/// goes away.

abstract class _$SignUpController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
