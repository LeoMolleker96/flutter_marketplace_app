import 'package:network/network.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/params/sign_in_params.dart';
import '../../domain/params/sign_up_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../request_failure_cause.dart';

/// The real [AuthRepository], backed by a remote and a local data source.
///
/// It does two jobs. It **joins** the sources: signing in or signing up asks the
/// server for a token and, once it has one, hands it to the local source to
/// keep. And it **translates**: the data sources throw whatever the transport
/// throws, and this catches a `DioException` and rethrows an [AuthFailure], so
/// the use case, the view model and the screen never learn that dio exists.
///
/// The token never leaves this layer. Callers of [signIn] and [signUp] learn only
/// that it worked; reading the token back, to send it with requests, is a
/// separate concern for when something needs it.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates the repository over [remote] and [local].
  const AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  static const _badRequest = 400;
  static const _unauthorized = 401;
  static const _conflict = 409;

  @override
  Future<void> signIn(SignInParams params) {
    return _startSession(() => _remote.signIn(params));
  }

  @override
  Future<void> signUp(SignUpParams params) {
    return _startSession(() => _remote.signUp(params));
  }

  /// Runs [authenticate], keeps the token it returns, and translates failures.
  ///
  /// Signing in and signing up differ only in the request. What comes after is
  /// the same: the server answers with a token, the token is kept, and anything
  /// that goes wrong is reported as an [AuthFailure]. Doing that once means the
  /// two cannot drift apart.
  Future<void> _startSession(Future<String> Function() authenticate) async {
    final String token;

    try {
      token = await authenticate();
    } on DioException catch (error, stackTrace) {
      // Keep the original stack trace: the failure is a new type, but where it
      // really came from is still what you want when debugging.
      Error.throwWithStackTrace(_toFailure(error), stackTrace);
    } on FormatException catch (error, stackTrace) {
      // The server accepted the credentials but broke the agreed response
      // shape. That is the backend failing, not the user, so it is reported as
      // an unknown failure rather than as a bad password.
      Error.throwWithStackTrace(UnknownAuthFailure(cause: error), stackTrace);
    }

    // A separate step because the failure means something different: the server
    // has already said yes. Whatever the platform's store throws (a Keystore
    // error, WebCrypto unavailable outside a secure context) is reported as one
    // failure the screen can explain, instead of a raw exception that reads as
    // "the sign-up failed" when the account in fact exists.
    try {
      await _local.saveToken(token);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        SessionNotSavedFailure(cause: error),
        stackTrace,
      );
    }
  }

  AuthFailure _toFailure(DioException error) {
    // Never the DioException itself: it holds the request body, which is the
    // user's password. See RequestFailureCause.
    final cause = RequestFailureCause.from(error);

    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => ConnectionFailure(cause: cause),
      DioExceptionType.badResponse
          when error.response?.statusCode == _badRequest =>
        InvalidRequestFailure(cause: cause),
      DioExceptionType.badResponse
          when error.response?.statusCode == _unauthorized =>
        InvalidCredentialsFailure(cause: cause),
      DioExceptionType.badResponse
          when error.response?.statusCode == _conflict =>
        EmailAlreadyInUseFailure(cause: cause),
      _ => UnknownAuthFailure(cause: cause),
    };
  }
}
