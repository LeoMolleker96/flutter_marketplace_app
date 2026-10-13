import 'package:network/network.dart';

import '../../domain/params/sign_in_params.dart';
import '../../domain/params/sign_up_params.dart';

/// Talks to the authentication endpoints of the backend.
///
/// The lowest layer: it wraps the remote source and nothing else. It holds no
/// state and makes no decisions about what a failure means — whatever the
/// transport throws, it throws. Turning that into something the app understands
/// is the repository's job.
///
/// It does know the shape of the wire format, which is why it, and not the
/// repository, pulls the token out of the response.
abstract interface class AuthRemoteDataSource {
  /// Sends the credentials to the server and returns the session token it
  /// answers with.
  ///
  /// Throws a `DioException` when the request fails, and a [FormatException]
  /// when the server accepts the credentials but the response has no usable
  /// token.
  Future<String> signIn(SignInParams params);

  /// Asks the server to create an account and returns the session token it
  /// answers with, so the new user starts signed in.
  ///
  /// Throws a `DioException` when the request fails, and a [FormatException]
  /// when the server creates the account but the response has no usable token.
  Future<String> signUp(SignUpParams params);
}

/// The dio-backed [AuthRemoteDataSource].
///
/// The shapes below are the contract the backend implements, recorded here so
/// the two sides can be compared at a glance:
///
/// * sign-in: a `POST` to `/auth/sign-in` with a JSON body of `email` and
///   `password`; a `200` answers success and a `401` wrong credentials;
/// * sign-up: a `POST` to `/auth/sign-up` with a JSON body of `email` and
///   `password`; a `201` answers success and a `409` an email that already has
///   an account;
/// * for both, a `400` answers a malformed body;
/// * response, for both: a JSON body of `{"token": "<value>"}`.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Creates the data source over [dio], which already knows the base URL.
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  /// The sign-in endpoint, relative to the client's base URL.
  static const signInPath = '/auth/sign-in';

  /// The sign-up endpoint, relative to the client's base URL.
  static const signUpPath = '/auth/sign-up';

  @override
  Future<String> signIn(SignInParams params) {
    return _requestToken(signInPath, {
      'email': params.email,
      'password': params.password,
    });
  }

  @override
  Future<String> signUp(SignUpParams params) {
    return _requestToken(signUpPath, {
      'email': params.email,
      'password': params.password,
    });
  }

  /// Posts [body] to [path] and returns the token in the answer.
  ///
  /// Both endpoints answer in the same shape, so reading it happens once.
  Future<String> _requestToken(String path, Map<String, String> body) async {
    // `Object?` rather than a map type: dio casts the body to the requested
    // type, and a server that answers with something else would then fail with
    // an opaque cast error instead of the FormatException below.
    final response = await _dio.post<Object?>(path, data: body);

    final data = response.data;
    final token = data is Map<String, Object?> ? data['token'] : null;

    if (token is! String || token.isEmpty) {
      throw FormatException('The response from $path has no token.');
    }

    return token;
  }
}
