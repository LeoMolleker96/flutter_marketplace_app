import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_app/core/router/app_router.dart';
import 'package:marketplace_app/core/widgets/app_checkbox.dart';
import 'package:marketplace_app/core/widgets/app_primary_button.dart';
import 'package:marketplace_app/features/auth/presentation/views/login_view.dart';
import 'package:marketplace_app/features/listings/presentation/views/listings_view.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  /// A fresh router per test.
  ///
  /// The app's own `appRouter` is a top-level value that holds the current
  /// location, so sharing it would leak navigation from one test into the next.
  GoRouter buildRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: AppRoutes.listings,
          builder: (context, state) => const ListingsView(),
        ),
      ],
    );
  }

  group('layout', () {
    testWidgets('renders every section at compact width', (tester) async {
      await tester.pumpApp(const LoginView());

      expect(find.text('Welcome back'), findsOneWidget);
      expect(
        find.text('Discover unique finds and connect with trusted sellers'),
        findsOneWidget,
      );
      expect(find.text('Email or Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Face ID'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Or Continue With'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
      expect(find.textContaining('Terms of Service'), findsOneWidget);
    });

    testWidgets('renders every section at expanded width', (tester) async {
      await tester.pumpApp(const LoginView(), size: expandedSize);

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email or Username'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('caps the content column on a wide window', (tester) async {
      await tester.pumpApp(const LoginView(), size: expandedSize);

      // Without the cap the card would stretch to the full 1000px, which is
      // the classic way a mobile-first form breaks on the web.
      final cardWidth = tester.getSize(find.byType(TextField).first).width;

      expect(cardWidth, lessThanOrEqualTo(440));
    });

    testWidgets('scrolls rather than overflowing on a short window',
        (tester) async {
      await tester.pumpApp(const LoginView(), size: const Size(400, 600));

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('remember me', () {
    testWidgets('starts unchecked and toggles both ways', (tester) async {
      await tester.pumpApp(const LoginView());

      // Scoped to the checkbox: the brand mark's verified badge is also an
      // Icons.check, so a bare byIcon finder matches the wrong widget.
      final checkMark = find.descendant(
        of: find.byType(AppCheckbox),
        matching: find.byIcon(Icons.check),
      );

      expect(checkMark, findsNothing);

      await tester.tap(find.text('Remember me'));
      await tester.pump();
      expect(checkMark, findsOneWidget);

      await tester.tap(find.text('Remember me'));
      await tester.pump();
      expect(checkMark, findsNothing);
    });
  });

  group('password visibility', () {
    testWidgets('the password field starts obscured', (tester) async {
      await tester.pumpApp(const LoginView());

      final fields = tester.widgetList<TextField>(find.byType(TextField));

      expect(fields.first.obscureText, isFalse, reason: 'email is not hidden');
      expect(fields.last.obscureText, isTrue, reason: 'password is hidden');
    });
  });

  group('submit availability', () {
    bool submitEnabled(WidgetTester tester) =>
        tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton)).enabled;

    Future<void> fill(
      WidgetTester tester, {
      String? email,
      String? password,
    }) async {
      if (email != null) {
        await tester.enterText(find.byType(TextField).first, email);
      }
      if (password != null) {
        await tester.enterText(find.byType(TextField).last, password);
      }
      await tester.pump();
    }

    testWidgets('starts disabled with both fields empty', (tester) async {
      await tester.pumpApp(const LoginView());

      expect(submitEnabled(tester), isFalse);
    });

    testWidgets('stays disabled with only the email filled', (tester) async {
      await tester.pumpApp(const LoginView());

      await fill(tester, email: 'ana@example.com');

      expect(submitEnabled(tester), isFalse);
    });

    testWidgets('stays disabled with only the password filled',
        (tester) async {
      await tester.pumpApp(const LoginView());

      await fill(tester, password: 'hunter22');

      expect(submitEnabled(tester), isFalse);
    });

    testWidgets('ignores an email of nothing but whitespace', (tester) async {
      await tester.pumpApp(const LoginView());

      await fill(tester, email: '   ', password: 'hunter22');

      expect(submitEnabled(tester), isFalse);
    });

    testWidgets('enables once both fields have content', (tester) async {
      await tester.pumpApp(const LoginView());

      await fill(tester, email: 'ana@example.com', password: 'hunter22');

      expect(submitEnabled(tester), isTrue);
    });

    testWidgets('disables again when a field is cleared', (tester) async {
      await tester.pumpApp(const LoginView());

      await fill(tester, email: 'ana@example.com', password: 'hunter22');
      expect(submitEnabled(tester), isTrue);

      await fill(tester, email: '');

      expect(submitEnabled(tester), isFalse);
    });
  });

  group('navigation', () {
    Future<void> fillCredentials(WidgetTester tester) async {
      await tester.enterText(find.byType(TextField).first, 'ana@example.com');
      await tester.enterText(find.byType(TextField).last, 'hunter22');
      await tester.pump();
    }

    testWidgets('Log In goes to the listings screen', (tester) async {
      await tester.pumpRouter(buildRouter());

      expect(find.text('Welcome back'), findsOneWidget);

      await fillCredentials(tester);
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Listings'), findsOneWidget);
      expect(find.text('Welcome back'), findsNothing);
    });

    testWidgets('does not navigate while the form is incomplete',
        (tester) async {
      await tester.pumpRouter(buildRouter());

      await tester.tap(find.text('Log In'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Listings'), findsNothing);
    });

    testWidgets('replaces the login screen instead of stacking on it',
        (tester) async {
      // `go` rather than `push`: after signing in, the back button must not
      // return to the login form.
      final router = buildRouter();
      await tester.pumpRouter(router);

      await fillCredentials(tester);
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(router.canPop(), isFalse);
    });
  });
}
