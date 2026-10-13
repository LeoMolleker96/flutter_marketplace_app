import '../params/sign_in_params.dart';
import '../params/sign_up_params.dart';

/// Authentication, as the rest of the feature needs it.
///
/// This is the **interface**, and it lives in `domain` on purpose: the
/// implementation will live in `data`, which depends on `domain` and never the
/// other way round. Presentation talks only to this contract, so it can be built
/// and tested without a backend, and swapping the implementation touches no view
/// model.
abstract interface class AuthRepository {
  /// Signs in with the given credentials.
  ///
  /// Completes normally once the user is signed in, and throws an
  /// `AuthFailure` if the attempt fails.
  Future<void> signIn(SignInParams params);

  /// Creates an account and signs the new user in.
  ///
  /// Completes normally once the account exists and the session is started, and
  /// throws an `AuthFailure` if the attempt fails. Starting the session is part
  /// of the contract so that nobody has to sign in a second time right after
  /// signing up.
  Future<void> signUp(SignUpParams params);
}
