import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/sign_up_use_case.dart';
import 'auth_repository_provider.dart';

part 'sign_up_use_case_provider.g.dart';

/// The [SignUpUseCase] the view model runs.
///
/// Built from the same repository as the sign-in use case, so one override of
/// `authRepositoryProvider` points both flows at a different implementation.
///
/// Auto-disposed for the same reason as the sign-in one: the use case holds no
/// state, and the repository underneath is the long-lived piece.
@riverpod
SignUpUseCase signUpUseCase(Ref ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
}
