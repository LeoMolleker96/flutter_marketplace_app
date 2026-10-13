import '../params/sign_in_params.dart';
import '../repositories/auth_repository.dart';

/// Signs a user in.
///
/// One business operation, callable like a function: `await signIn(params)`.
///
/// Today it only forwards to the repository, so it adds no logic of its own. It
/// earns its place when the operation grows beyond one call — validating before
/// sending, combining two repositories, recording the attempt — and it gives
/// those rules a home that is neither a widget nor a view model.
class SignInUseCase {
  /// Creates the use case over [repository].
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  /// Signs in with [params].
  ///
  /// Completes once the user is signed in, and throws an `AuthFailure` if not.
  Future<void> call(SignInParams params) => _repository.signIn(params);
}
