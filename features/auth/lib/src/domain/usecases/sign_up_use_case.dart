import '../failures/auth_failure.dart';
import '../params/sign_up_params.dart';
import '../repositories/auth_repository.dart';
import '../rules/sign_up_rules.dart';

/// Creates an account and leaves the user signed in.
///
/// One business operation, callable like a function: `await signUp(params)`.
///
/// It is the entry point for the sign-up rules (see docs/adr/0008): it checks
/// them with `SignUpRules` before the repository is called, so the server is
/// never asked to create an account the app already knows is invalid. The
/// view's disabled button spares the person the error; this is what guarantees
/// it for any caller.
class SignUpUseCase {
  /// Creates the use case over [repository].
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  /// Creates the account described by [params].
  ///
  /// Completes once the account exists and the user is signed in. Throws
  /// [InvalidSignUpFailure], without any request, if the email is not an address
  /// or the password does not meet every requirement; otherwise throws the
  /// `AuthFailure` the repository reports.
  ///
  /// The password confirmation is not checked here: it belongs to the form, and
  /// [SignUpParams] does not carry it.
  // `async` so the failure always arrives through the returned Future, like
  // every other failure, and never as a synchronous throw.
  Future<void> call(SignUpParams params) async {
    if (!SignUpRules.isValidEmail(params.email) ||
        !SignUpRules.isValidPassword(params.password)) {
      throw const InvalidSignUpFailure();
    }
    await _repository.signUp(params);
  }
}
