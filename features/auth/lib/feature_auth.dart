/// The authentication feature.
///
/// Exposes screens, never routes: where a screen lives and what happens after
/// it finishes is the app shell's decision, passed in as callbacks. That keeps
/// this package ignorant of every other feature.
///
/// Also exposes what the app shell needs to assemble the feature:
/// [authRepositoryProvider], which it overrides with the real implementation,
/// the [AuthRepositoryImpl] and the two data sources that make it up, and the
/// [AuthRepository] contract and the [SignInParams] and [SignUpParams] they
/// speak.
library;

export 'src/data/datasources/auth_local_data_source.dart';
export 'src/data/datasources/auth_remote_data_source.dart';
export 'src/data/repositories/auth_repository_impl.dart';
export 'src/domain/params/sign_in_params.dart';
export 'src/domain/params/sign_up_params.dart';
export 'src/domain/repositories/auth_repository.dart';
export 'src/presentation/providers/auth_repository_provider.dart';
export 'src/presentation/views/sign_in_view.dart';
export 'src/presentation/views/sign_up_view.dart';
