import 'package:design_system/design_system.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/di/app_overrides.dart';
import 'package:marketplace_app/di/dio_provider.dart';
import 'package:marketplace_app/router/app_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network/network.dart';

import '../helpers/mock_http_client_adapter.dart';

/// Stands in for the platform's secure store, which a widget test cannot
/// reach; tests ask it what it was told to keep.
class _MockLocalDataSource extends Mock implements AuthLocalDataSource {}

/// These tests exercise the composition root: the one thing only the app shell
/// owns. Nothing is faked above the network and the device store — the real
/// screen, controller, use case, repository, data source and dio client all run,
/// and only the adapter that would send the request, and the store that would
/// keep the token, are replaced.
///
/// They prove the chain is connected (the request leaves for the right endpoint
/// and the token reaches the store). What each failure looks like on screen, and
/// how it is translated, is `feature_auth`'s to test, in its own package.
void main() {
  late _MockLocalDataSource store;

  setUp(() {
    store = _MockLocalDataSource();
    when(() => store.saveToken(any())).thenAnswer((_) async {});
  });

  /// Mounts the real app, assembled by [appOverrides], over [adapter].
  Future<void> pumpApp(
    WidgetTester tester,
    MockHttpClientAdapter adapter,
  ) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...appOverrides(authLocalDataSource: store),
          dioProvider.overrideWithValue(dio),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: createAppRouter(),
        ),
      ),
    );
  }

  Future<void> signIn(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, 'ana@example.com');
    await tester.enterText(find.byType(TextField).last, 'hunter22');
    await tester.pump();
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
  }

  testWidgets('sign-in sends the typed credentials to POST /auth/sign-in', (
    tester,
  ) async {
    final adapter = stubAdapter(status: 200);
    await pumpApp(tester, adapter);

    await signIn(tester);

    final request = sentRequests(adapter).single;
    expect(request.method, 'POST');
    expect(request.uri.toString(), 'https://api.test/auth/sign-in');
    expect(request.data, {'email': 'ana@example.com', 'password': 'hunter22'});
  });

  testWidgets('sign-in keeps the token the backend answers with', (
    tester,
  ) async {
    await pumpApp(
      tester,
      stubAdapter(status: 200, body: '{"token":"abc.def.ghi"}'),
    );

    await signIn(tester);

    verify(() => store.saveToken('abc.def.ghi')).called(1);
  });

  group('signing up', () {
    /// Opens the sign-up screen from sign-in, fills it in and submits it.
    Future<void> signUp(WidgetTester tester) async {
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'ana@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'Hunter22!');
      await tester.enterText(find.byType(TextField).at(2), 'Hunter22!');
      await tester.pump();
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
    }

    testWidgets('sends the typed details to POST /auth/sign-up', (
      tester,
    ) async {
      final adapter = stubAdapter(status: 201);
      await pumpApp(tester, adapter);

      await signUp(tester);

      final request = sentRequests(adapter).single;
      expect(request.method, 'POST');
      expect(request.uri.toString(), 'https://api.test/auth/sign-up');
      expect(request.data, {
        'email': 'ana@example.com',
        'password': 'Hunter22!',
      });
    });

    testWidgets('keeps the token the backend answers with', (tester) async {
      await pumpApp(
        tester,
        stubAdapter(status: 201, body: '{"token":"new.user.token"}'),
      );

      await signUp(tester);

      verify(() => store.saveToken('new.user.token')).called(1);
    });
  });

  test('the client points at the local backend unless told otherwise', () {
    final container = ProviderContainer.test();

    expect(
      container.read(dioProvider).options.baseUrl,
      'http://localhost:3000',
    );
  });
}
