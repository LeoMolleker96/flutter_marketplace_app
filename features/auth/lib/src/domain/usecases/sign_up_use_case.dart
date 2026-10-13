import '../params/sign_up_params.dart';
import '../repositories/auth_repository.dart';

/// Creates an account and leaves the user signed in.
///
/// One business operation, callable like a function: `await signUp(params)`.
///
/// Like `SignInUseCase`, today it only forwards to the repository. It is its own
/// class because creating an account and signing in are different operations
/// that will grow differently — sign-up is where email confirmation or terms
/// acceptance would be added.
class SignUpUseCase {
  /// Creates the use case over [repository].
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  /// Creates the account described by [params].
  ///
  /// Completes once the account exists and the user is signed in, and throws an
  /// `AuthFailure` if not.
  Future<void> call(SignUpParams params) => _repository.signUp(params);
}
