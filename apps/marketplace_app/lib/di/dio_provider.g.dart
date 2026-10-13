// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The HTTP client every feature's data layer uses.
///
/// Declared here, in the app shell, because it is where two packages that must
/// not know each other meet: `network` builds the client but has no idea what an
/// expired session means, and the features need a client but must not build one.
/// The shell is the one place allowed to connect them.
///
/// `onUnauthorized` is deliberately empty for now. Nothing in the app tracks a
/// session yet, so there is nothing to close. When a session exists, signing out
/// goes here — through `ref`, which is why this is a provider.
///
/// `keepAlive`, because a client is shared by the whole app and rebuilding it
/// would also reset the interceptor's one-shot 401 latch.

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// The HTTP client every feature's data layer uses.
///
/// Declared here, in the app shell, because it is where two packages that must
/// not know each other meet: `network` builds the client but has no idea what an
/// expired session means, and the features need a client but must not build one.
/// The shell is the one place allowed to connect them.
///
/// `onUnauthorized` is deliberately empty for now. Nothing in the app tracks a
/// session yet, so there is nothing to close. When a session exists, signing out
/// goes here — through `ref`, which is why this is a provider.
///
/// `keepAlive`, because a client is shared by the whole app and rebuilding it
/// would also reset the interceptor's one-shot 401 latch.

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// The HTTP client every feature's data layer uses.
  ///
  /// Declared here, in the app shell, because it is where two packages that must
  /// not know each other meet: `network` builds the client but has no idea what an
  /// expired session means, and the features need a client but must not build one.
  /// The shell is the one place allowed to connect them.
  ///
  /// `onUnauthorized` is deliberately empty for now. Nothing in the app tracks a
  /// session yet, so there is nothing to close. When a session exists, signing out
  /// goes here — through `ref`, which is why this is a provider.
  ///
  /// `keepAlive`, because a client is shared by the whole app and rebuilding it
  /// would also reset the interceptor's one-shot 401 latch.
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'06cc1cb0103bf4a08751ee3b88b86e1bded91c16';
