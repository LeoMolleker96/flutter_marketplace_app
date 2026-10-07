import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_app/router/app_router.dart';

void main() {
  /// Mounts the app's real route table.
  ///
  /// A fresh router each time: the global `appRouter` keeps its location, so
  /// sharing it would carry navigation from one test into the next.
  Future<GoRouter> pumpRoutes(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = createAppRouter();
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );

    return router;
  }

  Future<void> fillCredentials(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, 'ana@example.com');
    await tester.enterText(find.byType(TextField).last, 'hunter22');
    await tester.pump();
  }

  testWidgets('opens on the login screen', (tester) async {
    await pumpRoutes(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Listings'), findsNothing);
  });

  testWidgets('Log In goes to the listings screen', (tester) async {
    await pumpRoutes(tester);

    await fillCredentials(tester);
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Listings'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
  });

  testWidgets('does not navigate while the form is incomplete',
      (tester) async {
    await pumpRoutes(tester);

    await tester.tap(find.text('Log In'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Listings'), findsNothing);
  });

  testWidgets('replaces the login screen instead of stacking on it',
      (tester) async {
    // `go` rather than `push`: after signing in, the back button must not
    // return to the login form.
    final router = await pumpRoutes(tester);

    await fillCredentials(tester);
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(router.canPop(), isFalse);
  });
}
