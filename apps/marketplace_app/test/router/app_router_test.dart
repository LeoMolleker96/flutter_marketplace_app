import 'package:design_system/design_system.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_app/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const SignInParams(email: 'ana', password: 'hunter22'),
    );
    registerFallbackValue(
      const SignUpParams(email: 'ana@example.com', password: 'Hunter22!'),
    );
  });

  /// A repository standing in for the real one, so no request leaves the test.
  ///
  /// With [fails] set, both sign-in and sign-up are rejected.
  _MockAuthRepository repositoryThat({required bool fails}) {
    final repository = _MockAuthRepository();
    Future<void> answer(Invocation _) async {
      if (fails) throw StateError('rejected');
    }

    when(() => repository.signIn(any())).thenAnswer(answer);
    when(() => repository.signUp(any())).thenAnswer(answer);
    return repository;
  }

  /// Mounts the app's real route table inside a ProviderScope.
  ///
  /// A fresh router each time: the global `appRouter` keeps its location, so
  /// sharing it would carry navigation from one test into the next.
  ///
  /// [fails] decides whether the mock repository accepts the sign-in. The
  /// screens read their controller from the scope, so the repository is the one
  /// thing a test has to supply.
  Future<GoRouter> pumpRoutes(WidgetTester tester, {bool fails = false}) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = createAppRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            repositoryThat(fails: fails),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );

    return router;
  }

  Future<void> fillCredentials(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, 'ana@example.com');
    await tester.enterText(find.byType(TextField).last, 'hunter22');
    await tester.pump();
  }

  testWidgets('opens on the sign-in screen', (tester) async {
    await pumpRoutes(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Listings'), findsNothing);
  });

  testWidgets('a successful sign-in goes to the listings screen', (
    tester,
  ) async {
    await pumpRoutes(tester);

    await fillCredentials(tester);
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Listings'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
  });

  testWidgets('a failed sign-in stays on the sign-in screen', (tester) async {
    await pumpRoutes(tester, fails: true);

    await fillCredentials(tester);
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Listings'), findsNothing);
  });

  testWidgets('does not navigate while the form is incomplete', (tester) async {
    await pumpRoutes(tester);

    await tester.tap(find.text('Sign In'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Listings'), findsNothing);
  });

  testWidgets('"Sign up" on the sign-in screen opens the sign-up screen', (
    tester,
  ) async {
    final router = await pumpRoutes(tester);

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Join Agora'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
    expect(router.state.uri.toString(), AppRoutes.signUp);
  });

  testWidgets('"Sign in" on the sign-up screen returns to sign-in', (
    tester,
  ) async {
    final router = await pumpRoutes(tester);
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Join Agora'), findsNothing);
    expect(router.state.uri.toString(), AppRoutes.signIn);
  });

  testWidgets('the sign-up screen has its own URL', (tester) async {
    // Every route is a real URL on web (CLAUDE.md section 6), so the screen must
    // be reachable by address, not only by tapping through to it.
    final router = await pumpRoutes(tester);

    router.go(AppRoutes.signUp);
    await tester.pumpAndSettle();

    expect(find.text('Join Agora'), findsOneWidget);
  });

  Future<void> fillSignUp(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).at(0), 'ana@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'Hunter22!');
    await tester.enterText(find.byType(TextField).at(2), 'Hunter22!');
    await tester.pump();
  }

  testWidgets('a successful sign-up goes to the listings screen', (
    tester,
  ) async {
    final router = await pumpRoutes(tester);
    router.go(AppRoutes.signUp);
    await tester.pumpAndSettle();

    await fillSignUp(tester);
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Listings'), findsOneWidget);
    expect(find.text('Join Agora'), findsNothing);
    expect(router.canPop(), isFalse, reason: 'back must not reopen the form');
  });

  testWidgets('a failed sign-up stays on the sign-up screen', (tester) async {
    final router = await pumpRoutes(tester, fails: true);
    router.go(AppRoutes.signUp);
    await tester.pumpAndSettle();

    await fillSignUp(tester);
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Join Agora'), findsOneWidget);
    expect(find.text('Listings'), findsNothing);
  });

  // An unknown address must show fixed copy and never echo the URL: the
  // location is attacker-controlled, so printing it is a phishing vector.
  const unknownPaths = ['/does-not-exist', '/Your%20account%20is%20suspended'];
  const windowSizes = {'compact': Size(400, 800), 'expanded': Size(1000, 800)};

  for (final MapEntry(key: sizeName, value: size) in windowSizes.entries) {
    for (final path in unknownPaths) {
      testWidgets('$path shows the not-found page at $sizeName width', (
        tester,
      ) async {
        final router = await pumpRoutes(tester);
        tester.view.physicalSize = size;

        router.go(path);
        await tester.pumpAndSettle();

        expect(find.text('Page not found'), findsOneWidget);
        expect(find.textContaining('suspended'), findsNothing);
        expect(find.textContaining('does-not-exist'), findsNothing);
        expect(find.textContaining('GoException'), findsNothing);
        expect(find.text('Welcome back'), findsNothing);
      });

      testWidgets('"Go to home" leaves $path for the sign-in screen at '
          '$sizeName width', (tester) async {
        final router = await pumpRoutes(tester);
        tester.view.physicalSize = size;

        router.go(path);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Go to home'));
        await tester.pumpAndSettle();

        expect(find.text('Welcome back'), findsOneWidget);
        expect(find.text('Page not found'), findsNothing);
        expect(router.state.uri.toString(), AppRoutes.signIn);
      });
    }
  }

  testWidgets('replaces the sign-in screen instead of stacking on it', (
    tester,
  ) async {
    // `go` rather than `push`: after signing in, the back button must not
    // return to the sign-in form.
    final router = await pumpRoutes(tester);

    await fillCredentials(tester);
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(router.canPop(), isFalse);
  });
}
