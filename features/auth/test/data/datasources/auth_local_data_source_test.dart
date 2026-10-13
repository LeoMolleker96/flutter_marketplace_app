import 'package:feature_auth/src/data/datasources/auth_local_data_source.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The real store talks to platform code that does not exist in a unit test.
  // The package ships an in-memory replacement for exactly this.
  const storage = FlutterSecureStorage();
  const key = AuthLocalDataSourceImpl.tokenKey;

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('stores the token under the documented key', () async {
    await const AuthLocalDataSourceImpl().saveToken('abc.def.ghi');

    expect(await storage.read(key: key), 'abc.def.ghi');
  });

  test('replaces a previous token', () async {
    const dataSource = AuthLocalDataSourceImpl();

    await dataSource.saveToken('first');
    await dataSource.saveToken('second');

    expect(await storage.read(key: key), 'second');
  });

  test('stores the token untouched', () async {
    // A token is opaque; nothing may trim or reformat it on the way in.
    await const AuthLocalDataSourceImpl().saveToken('  Spaced-Token==  ');

    expect(await storage.read(key: key), '  Spaced-Token==  ');
  });

  test('keeps only the token, nothing else', () async {
    await const AuthLocalDataSourceImpl().saveToken('abc');

    expect(await storage.readAll(), {key: 'abc'});
  });
}
