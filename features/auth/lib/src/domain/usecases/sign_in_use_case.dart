import '../params/sign_in_params.dart';
import '../repositories/auth_repository.dart';

/// Signs a user in.
///
/// One business operation, callable like a function: `await signIn(params)`.
///
/// It is the single entry point for sign-in rules, and presentation calls it
/// rather than the repository (see docs/adr/0008). There are no sign-in rules
/// today, so it only forwards; it exists so that the day one appears —
/// validating before sending, combining two repositories, recording the attempt
/// — it has a home that is neither a widget nor a view model.
class SignInUseCase {
  /// Creates the use case over [repository].
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  /// Signs in with [params].
  ///
  /// Completes once the user is signed in, and throws an `AuthFailure` if not.
  Future<void> call(SignInParams params) => _repository.signIn(params);
}
