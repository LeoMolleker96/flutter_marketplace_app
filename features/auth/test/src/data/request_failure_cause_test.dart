import 'package:feature_auth/src/data/request_failure_cause.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

DioException _error({int? status, String path = '/auth/sign-in'}) {
  final request = RequestOptions(
    path: path,
    queryParameters: {'token': 'in-the-query'},
    data: {'email': 'ana@example.com', 'password': 'hunter22'},
  );

  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: status == null
        ? null
        : Response<Object?>(
            requestOptions: request,
            statusCode: status,
            data: {'echo': 'hunter22'},
          ),
  );
}

void main() {
  test('keeps the kind of failure, the status and the endpoint', () {
    final cause = RequestFailureCause.from(_error(status: 401));

    expect(cause.type, DioExceptionType.badResponse);
    expect(cause.statusCode, 401);
    expect(cause.path, '/auth/sign-in');
  });

  test('has no status when the server never answered', () {
    expect(RequestFailureCause.from(_error()).statusCode, isNull);
  });

  test('prints something useful for debugging', () {
    expect(
      RequestFailureCause.from(_error(status: 409)).toString(),
      'RequestFailureCause(badResponse, path: /auth/sign-in, status: 409)',
    );
  });

  test('prints nothing that came from the user or the server body', () {
    final text = RequestFailureCause.from(_error(status: 401)).toString();

    expect(text, isNot(contains('hunter22')));
    expect(text, isNot(contains('ana@example.com')));
    expect(text, isNot(contains('in-the-query')));
  });

  test('does not hold the exception it was made from', () {
    final cause = RequestFailureCause.from(_error(status: 401));

    expect(cause, isNot(isA<DioException>()));
  });
}
