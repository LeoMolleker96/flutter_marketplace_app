import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/sign_in_use_case.dart';
import 'auth_repository_provider.dart';

part 'sign_in_use_case_provider.g.dart';

/// The [SignInUseCase] the view model runs.
///
/// Built from the repository, so overriding `authRepositoryProvider` is all it
/// takes to point the whole chain — controller, use case, repository — at a
/// different implementation, in the app or in a test.
///
/// Auto-disposed: the use case holds no state of its own, so there is nothing
/// worth keeping alive. The repository underneath is the long-lived piece.
@riverpod
SignInUseCase signInUseCase(Ref ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
}
