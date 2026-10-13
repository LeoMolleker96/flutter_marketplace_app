// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The [AuthRepository] the feature talks to.
///
/// Deliberately unimplemented. Presentation may only depend on `domain`, so it
/// cannot name the real implementation, which lives in `data`. Whoever assembles
/// the app overrides this provider with that implementation:
///
/// ```dart
/// ProviderScope(overrides: [
///   authRepositoryProvider.overrideWith((ref) => RealAuthRepository(...)),
/// ])
/// ```
///
/// Until then, reading it throws — which is the right failure: a sign-in attempt
/// with no repository wired is a programming error, not something to recover
/// from.
///
/// `keepAlive` because a repository is shared state for the whole app; letting
/// it dispose and rebuild whenever no screen is listening would throw away
/// anything it caches.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// The [AuthRepository] the feature talks to.
///
/// Deliberately unimplemented. Presentation may only depend on `domain`, so it
/// cannot name the real implementation, which lives in `data`. Whoever assembles
/// the app overrides this provider with that implementation:
///
/// ```dart
/// ProviderScope(overrides: [
///   authRepositoryProvider.overrideWith((ref) => RealAuthRepository(...)),
/// ])
/// ```
///
/// Until then, reading it throws — which is the right failure: a sign-in attempt
/// with no repository wired is a programming error, not something to recover
/// from.
///
/// `keepAlive` because a repository is shared state for the whole app; letting
/// it dispose and rebuild whenever no screen is listening would throw away
/// anything it caches.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// The [AuthRepository] the feature talks to.
  ///
  /// Deliberately unimplemented. Presentation may only depend on `domain`, so it
  /// cannot name the real implementation, which lives in `data`. Whoever assembles
  /// the app overrides this provider with that implementation:
  ///
  /// ```dart
  /// ProviderScope(overrides: [
  ///   authRepositoryProvider.overrideWith((ref) => RealAuthRepository(...)),
  /// ])
  /// ```
  ///
  /// Until then, reading it throws — which is the right failure: a sign-in attempt
  /// with no repository wired is a programming error, not something to recover
  /// from.
  ///
  /// `keepAlive` because a repository is shared state for the whole app; letting
  /// it dispose and rebuild whenever no screen is listening would throw away
  /// anything it caches.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'e91313426c863a7166d4c2f45223e424b35b4ab8';
