// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks one sign-in attempt: idle, in flight, succeeded, or failed.
///
/// An `AsyncNotifier<void>` because it models an **action**, not data. There is
/// nothing to load when it is created, so `build` is empty and the value is
/// `void`; what matters is the `AsyncValue` around it, which already is the
/// loading / data / error union a view needs. Coming from Bloc, think of it as
/// the Cubit whose state is the progress of a single call.
///
/// Auto-disposed on purpose: it belongs to the sign-in screen and should reset
/// when the screen goes away. Who is signed in *right now* is a different
/// question, owned by the session, not by this controller.

@ProviderFor(SignInController)
final signInControllerProvider = SignInControllerProvider._();

/// Tracks one sign-in attempt: idle, in flight, succeeded, or failed.
///
/// An `AsyncNotifier<void>` because it models an **action**, not data. There is
/// nothing to load when it is created, so `build` is empty and the value is
/// `void`; what matters is the `AsyncValue` around it, which already is the
/// loading / data / error union a view needs. Coming from Bloc, think of it as
/// the Cubit whose state is the progress of a single call.
///
/// Auto-disposed on purpose: it belongs to the sign-in screen and should reset
/// when the screen goes away. Who is signed in *right now* is a different
/// question, owned by the session, not by this controller.
final class SignInControllerProvider
    extends $AsyncNotifierProvider<SignInController, void> {
  /// Tracks one sign-in attempt: idle, in flight, succeeded, or failed.
  ///
  /// An `AsyncNotifier<void>` because it models an **action**, not data. There is
  /// nothing to load when it is created, so `build` is empty and the value is
  /// `void`; what matters is the `AsyncValue` around it, which already is the
  /// loading / data / error union a view needs. Coming from Bloc, think of it as
  /// the Cubit whose state is the progress of a single call.
  ///
  /// Auto-disposed on purpose: it belongs to the sign-in screen and should reset
  /// when the screen goes away. Who is signed in *right now* is a different
  /// question, owned by the session, not by this controller.
  SignInControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInControllerHash();

  @$internal
  @override
  SignInController create() => SignInController();
}

String _$signInControllerHash() => r'2d96923704fbeb9742d48710a3d54469f83c370a';

/// Tracks one sign-in attempt: idle, in flight, succeeded, or failed.
///
/// An `AsyncNotifier<void>` because it models an **action**, not data. There is
/// nothing to load when it is created, so `build` is empty and the value is
/// `void`; what matters is the `AsyncValue` around it, which already is the
/// loading / data / error union a view needs. Coming from Bloc, think of it as
/// the Cubit whose state is the progress of a single call.
///
/// Auto-disposed on purpose: it belongs to the sign-in screen and should reset
/// when the screen goes away. Who is signed in *right now* is a different
/// question, owned by the session, not by this controller.

abstract class _$SignInController extends $AsyncNotifier<void> {
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
