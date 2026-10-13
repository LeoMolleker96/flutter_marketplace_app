import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/auth_repository.dart';

part 'auth_repository_provider.g.dart';

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
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  throw UnimplementedError(
    'authRepositoryProvider has no implementation. Override it where the app '
    'is assembled.',
  );
}
