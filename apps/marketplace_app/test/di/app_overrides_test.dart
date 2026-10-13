import 'package:design_system/design_system.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/di/app_overrides.dart';
import 'package:marketplace_app/di/dio_provider.dart';
import 'package:marketplace_app/router/app_router.dart';
import 'package:network/network.dart';

import '../helpers/fake_http_adapter.dart';

/// Keeps tokens in memory, in place of the platform's secure store, which a
/// widget test cannot reach.
class _MemoryLocalDataSource implements AuthLocalDataSource {
  final saved = <String>[];

  /// When set, every save fails with it, as a broken Keystore would.
  Object? failWith;

  @override
  Future<void> saveToken(String token) async {
    final failure = failWith;
    if (failure != null) throw failure;
    saved.add(token);
  }
}

/// These tests exercise the composition root: the one thing only the app shell
/// owns. Nothing is faked above the network and the device store — the real
/// screen, controller, use case, repository, data source and dio client all run,
/// and only the adapter that would send the request, and the store that would
/// keep the token, are replaced.
void main() {
  late _MemoryLocalDataSource store;

  setUp(() => store = _MemoryLocalDataSource());

  /// Mounts the real app, assembled by [appOverrides], over [adapter].
  Future<void> pumpApp(WidgetTester tester, FakeHttpAdapter adapter) async {
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

  testWidgets('sends the typed credentials to POST /auth/sign-in',
      (tester) async {
    final adapter = FakeHttpAdapter.status(200);
    await pumpApp(tester, adapter);

    await signIn(tester);

    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.uri.toString(), 'https://api.test/auth/sign-in');
    expect(request.data, {
      'username': 'ana@example.com',
      'password': 'hunter22',
    });
  });

  testWidgets('goes to the listings when the backend accepts the credentials',
      (tester) async {
    await pumpApp(tester, FakeHttpAdapter.status(200));

    await signIn(tester);

    expect(find.text('Listings'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
  });

  testWidgets('stays on sign-in when the backend rejects the credentials',
      (tester) async {
    await pumpApp(tester, FakeHttpAdapter.status(401));

    await signIn(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Listings'), findsNothing);
    expect(find.text('Incorrect username or password.'), findsOneWidget);
  });

  testWidgets('stays on sign-in when the backend cannot be reached',
      (tester) async {
    await pumpApp(tester, FakeHttpAdapter.unreachable());

    await signIn(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Listings'), findsNothing);
    expect(
      find.text("Can't reach the server. Check your connection and try again."),
      findsOneWidget,
    );
  });

  testWidgets('stays on sign-in when the backend fails', (tester) async {
    await pumpApp(tester, FakeHttpAdapter.status(500));

    await signIn(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  group('when the device cannot keep the session', () {
    testWidgets('sign-in says so, and stays on the screen', (tester) async {
      store.failWith = StateError('keystore unavailable');
      await pumpApp(tester, FakeHttpAdapter.status(200));

      await signIn(tester);

      expect(
        find.textContaining("couldn't keep your session"),
        findsOneWidget,
      );
      expect(find.text('Listings'), findsNothing);
    });
  });

  group('the session token', () {
    testWidgets('is kept when the backend answers with one', (tester) async {
      await pumpApp(
        tester,
        FakeHttpAdapter.status(200, body: '{"token":"abc.def.ghi"}'),
      );

      await signIn(tester);

      expect(store.saved, ['abc.def.ghi']);
    });

    testWidgets('is not kept when the credentials are rejected',
        (tester) async {
      await pumpApp(tester, FakeHttpAdapter.status(401));

      await signIn(tester);

      expect(store.saved, isEmpty);
    });

    testWidgets('is not kept when the backend cannot be reached',
        (tester) async {
      await pumpApp(tester, FakeHttpAdapter.unreachable());

      await signIn(tester);

      expect(store.saved, isEmpty);
    });

    testWidgets('a response without one is a failed sign-in', (tester) async {
      // The backend said yes but broke the agreed shape: nothing to keep, so
      // the user is not signed in and stays on the screen with a generic error.
      await pumpApp(tester, FakeHttpAdapter.status(200, body: '{}'));

      await signIn(tester);

      expect(store.saved, isEmpty);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Listings'), findsNothing);
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });
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
      await tester.tap(find.text('Crear cuenta'));
      await tester.pumpAndSettle();
    }

    testWidgets('sends the typed details to POST /auth/sign-up',
        (tester) async {
      final adapter = FakeHttpAdapter.status(201);
      await pumpApp(tester, adapter);

      await signUp(tester);

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.uri.toString(), 'https://api.test/auth/sign-up');
      expect(request.data, {
        'email': 'ana@example.com',
        'password': 'Hunter22!',
      });
    });

    testWidgets('keeps the token and goes to the listings on success',
        (tester) async {
      await pumpApp(
        tester,
        FakeHttpAdapter.status(201, body: '{"token":"new.user.token"}'),
      );

      await signUp(tester);

      expect(store.saved, ['new.user.token']);
      expect(find.text('Listings'), findsOneWidget);
      expect(find.text('Únete a Agora'), findsNothing);
    });

    testWidgets('says so when the email already has an account',
        (tester) async {
      await pumpApp(tester, FakeHttpAdapter.status(409));

      await signUp(tester);

      expect(find.text('Ya existe una cuenta con ese correo.'), findsOneWidget);
      expect(find.text('Listings'), findsNothing);
      expect(store.saved, isEmpty);
    });

    testWidgets('says so when the backend cannot be reached', (tester) async {
      await pumpApp(tester, FakeHttpAdapter.unreachable());

      await signUp(tester);

      expect(
        find.textContaining('No se puede conectar con el servidor'),
        findsOneWidget,
      );
      expect(store.saved, isEmpty);
    });

    testWidgets(
      'tells the person to sign in when the account exists but the session '
      'could not be kept',
      (tester) async {
        // The server created the account. Saying "something went wrong" would
        // invite a retry, and the retry would be refused as an email taken.
        store.failWith = StateError('keystore unavailable');
        await pumpApp(tester, FakeHttpAdapter.status(201));

        await signUp(tester);

        expect(find.textContaining('Tu cuenta se creó'), findsOneWidget);
        expect(find.textContaining('Inicia sesión para continuar'), findsOneWidget);
        expect(find.text('Listings'), findsNothing);
      },
    );

    testWidgets('a response without a token is a failed sign-up',
        (tester) async {
      await pumpApp(tester, FakeHttpAdapter.status(201, body: '{}'));

      await signUp(tester);

      expect(find.text('Algo salió mal. Inténtalo de nuevo.'), findsOneWidget);
      expect(find.text('Listings'), findsNothing);
      expect(store.saved, isEmpty);
    });
  });

  test('the client points at the local backend unless told otherwise', () {
    final container = ProviderContainer.test();

    expect(container.read(dioProvider).options.baseUrl, 'http://localhost:3000');
  });
}
