import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_auth/src/domain/failures/auth_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

/// A repository whose behaviour each test supplies, and which remembers what it
/// was asked to do.
class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository(this._onSignUp);

  final Future<void> Function(SignUpParams params) _onSignUp;

  final calls = <SignUpParams>[];

  @override
  Future<void> signUp(SignUpParams params) {
    calls.add(params);
    return _onSignUp(params);
  }
}

const _email = 'Correo electrónico';

void main() {
  SignUpView view({VoidCallback? onSignedUp, VoidCallback? onSignInTapped}) =>
      SignUpView(
        onSignedUp: onSignedUp ?? () {},
        onSignInTapped: onSignInTapped ?? () {},
      );

  List<Override> using(AuthRepository repository) =>
      [authRepositoryProvider.overrideWithValue(repository)];

  /// The three fields, in the order they appear.
  Finder field(int index) => find.byType(TextField).at(index);

  Future<void> fill(
    WidgetTester tester, {
    String? email,
    String? password,
    String? confirmation,
  }) async {
    if (email != null) await tester.enterText(field(0), email);
    if (password != null) await tester.enterText(field(1), password);
    if (confirmation != null) await tester.enterText(field(2), confirmation);
    await tester.pump();
  }

  Future<void> fillValidForm(WidgetTester tester) => fill(
        tester,
        email: 'ana@example.com',
        password: 'Hunter22!',
        confirmation: 'Hunter22!',
      );

  group('layout', () {
    testWidgets('renders every section at compact width', (tester) async {
      await tester.pumpApp(view());

      expect(find.text('Únete a Agora'), findsOneWidget);
      expect(
        find.text(
          'Descubre, compra y vende piezas únicas en una comunidad de confianza.',
        ),
        findsOneWidget,
      );
      expect(find.text(_email), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Confirmar contraseña'), findsOneWidget);
      expect(find.text('Crear cuenta'), findsOneWidget);
      expect(find.text('o'), findsOneWidget);
      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(find.text('¿Ya tienes cuenta? '), findsOneWidget);
      expect(find.text('Inicia sesión'), findsOneWidget);
      expect(find.textContaining('Términos de servicio'), findsOneWidget);
      expect(find.textContaining('Política de privacidad'), findsOneWidget);
    });

    testWidgets('renders every section at expanded width', (tester) async {
      await tester.pumpApp(view(), size: expandedSize);

      expect(find.text('Únete a Agora'), findsOneWidget);
      expect(find.text('Confirmar contraseña'), findsOneWidget);
      expect(find.text('Crear cuenta'), findsOneWidget);
    });

    testWidgets('caps the content column on a wide window', (tester) async {
      await tester.pumpApp(view(), size: expandedSize);

      expect(tester.getSize(field(0)).width, lessThanOrEqualTo(440));
    });

    testWidgets('scrolls rather than overflowing on a short window',
        (tester) async {
      await tester.pumpApp(view(), size: const Size(400, 600));

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('has no password strength indicator', (tester) async {
      // Left out on purpose: a different design is planned for it.
      await tester.pumpApp(view());

      expect(find.text('Segura'), findsNothing);
      expect(find.text('Débil'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });

  group('fields', () {
    testWidgets('has three, and only the two passwords are hidden',
        (tester) async {
      await tester.pumpApp(view());

      final hidden = tester
          .widgetList<TextField>(find.byType(TextField))
          .map((field) => field.obscureText)
          .toList();

      expect(hidden, [false, true, true]);
    });

    testWidgets('each password has its own visibility toggle', (tester) async {
      await tester.pumpApp(view());

      bool obscured(int index) =>
          tester.widget<TextField>(field(index)).obscureText;

      await tester.tap(find.byIcon(Icons.visibility).first);
      await tester.pump();

      expect(obscured(1), isFalse, reason: 'the first password was revealed');
      expect(obscured(2), isTrue, reason: 'the confirmation was left alone');
    });
  });

  group('validation messages', () {
    testWidgets('an untouched form complains about nothing', (tester) async {
      await tester.pumpApp(view());

      expect(find.text('Introduce un correo válido.'), findsNothing);
      expect(find.text('Las contraseñas no coinciden.'), findsNothing);
    });

    testWidgets('flags an email that is not an address', (tester) async {
      await tester.pumpApp(view());

      await fill(tester, email: 'ana');

      expect(find.text('Introduce un correo válido.'), findsOneWidget);
    });

    testWidgets('stops flagging the email once it is fixed', (tester) async {
      await tester.pumpApp(view());
      await fill(tester, email: 'ana');

      await fill(tester, email: 'ana@example.com');

      expect(find.text('Introduce un correo válido.'), findsNothing);
    });

    testWidgets('a short password adds no message to the field itself',
        (tester) async {
      // What is missing is said by the requirements list, not by a line of red
      // under the field.
      await tester.pumpApp(view());

      await fill(tester, password: 'short');

      expect(find.textContaining('Usa al menos'), findsNothing);
    });

    testWidgets('flags a confirmation that differs', (tester) async {
      await tester.pumpApp(view());

      await fill(tester, password: 'Hunter22!', confirmation: 'Hunter23!');

      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
    });

    testWidgets('re-checks the confirmation when the password changes',
        (tester) async {
      // The confirmation depends on the first password, so editing the first
      // after the second was typed must update the verdict.
      await tester.pumpApp(view());
      await fill(tester, password: 'Hunter22!', confirmation: 'Hunter22!');
      expect(find.text('Las contraseñas no coinciden.'), findsNothing);

      await fill(tester, password: 'Hunter23!');

      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
    });
  });

  group('password requirements', () {
    const labels = [
      'Mínimo 8 caracteres',
      'Una letra mayúscula',
      'Un número',
      'Un símbolo, como ! ? # @',
    ];

    // The password field's hint, "Mínimo 8 caracteres", has the same wording as the
    // first requirement. The requirement row comes later in the tree, so it is the
    // last match.
    Finder row(String label) => find.text(label).last;

    Color? colorOf(WidgetTester tester, String label) =>
        tester.widget<Text>(row(label)).style?.color;

    testWidgets('lists all four, in order, under the first password',
        (tester) async {
      await tester.pumpApp(view());

      final tops = [
        for (final label in labels) tester.getTopLeft(row(label)).dy,
      ];

      expect(tops, orderedEquals([...tops]..sort()));
      expect(
        tops.first,
        greaterThan(tester.getBottomLeft(field(1)).dy),
        reason: 'below the password field',
      );
      expect(
        tops.last,
        lessThan(tester.getTopLeft(find.text('Confirmar contraseña')).dy),
        reason: 'above the confirmation field',
      );
    });

    testWidgets('start red, before anything is typed', (tester) async {
      await tester.pumpApp(view());

      for (final label in labels) {
        expect(colorOf(tester, label), AppColors.error, reason: label);
      }
      expect(find.byIcon(Icons.cancel_outlined), findsNWidgets(4));
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    });

    testWidgets('each one turns green on its own as it is met',
        (tester) async {
      await tester.pumpApp(view());

      // Only a digit: just the number requirement.
      await fill(tester, password: '1');
      expect(colorOf(tester, 'Un número'), AppColors.tertiaryContainer);
      expect(colorOf(tester, 'Una letra mayúscula'), AppColors.error);
      expect(colorOf(tester, 'Un símbolo, como ! ? # @'), AppColors.error);
      expect(colorOf(tester, 'Mínimo 8 caracteres'), AppColors.error);

      // Add an uppercase letter.
      await fill(tester, password: '1A');
      expect(colorOf(tester, 'Una letra mayúscula'), AppColors.tertiaryContainer);
      expect(colorOf(tester, 'Un símbolo, como ! ? # @'), AppColors.error);

      // Add a symbol.
      await fill(tester, password: '1A!');
      expect(colorOf(tester, 'Un símbolo, como ! ? # @'),
          AppColors.tertiaryContainer);
      expect(colorOf(tester, 'Mínimo 8 caracteres'), AppColors.error);

      // Reach eight characters.
      await fill(tester, password: '1A!abcde');
      expect(colorOf(tester, 'Mínimo 8 caracteres'), AppColors.tertiaryContainer);
    });

    testWidgets('all turn green for a password that meets them all',
        (tester) async {
      await tester.pumpApp(view());

      await fill(tester, password: 'Hunter22!');

      for (final label in labels) {
        expect(colorOf(tester, label), AppColors.tertiaryContainer, reason: label);
      }
      expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(4));
      expect(find.byIcon(Icons.cancel_outlined), findsNothing);
    });

    testWidgets('go back to red when the password stops meeting them',
        (tester) async {
      await tester.pumpApp(view());
      await fill(tester, password: 'Hunter22!');

      await fill(tester, password: 'hunter22');

      expect(colorOf(tester, 'Una letra mayúscula'), AppColors.error);
      expect(colorOf(tester, 'Un símbolo, como ! ? # @'), AppColors.error);
      expect(colorOf(tester, 'Un número'), AppColors.tertiaryContainer);
    });

    testWidgets('a space is not a symbol', (tester) async {
      await tester.pumpApp(view());

      await fill(tester, password: 'my pass word');

      expect(colorOf(tester, 'Un símbolo, como ! ? # @'), AppColors.error);
    });

    testWidgets('are not shown for the confirmation field', (tester) async {
      await tester.pumpApp(view());

      await fill(tester, confirmation: 'Hunter22!');

      expect(find.text('Una letra mayúscula'), findsOneWidget);
      expect(colorOf(tester, 'Una letra mayúscula'), AppColors.error);
    });

    testWidgets('a screen reader hears whether each one is done',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpApp(view());

      expect(find.bySemanticsLabel('Un número: pendiente'), findsOneWidget);

      await fill(tester, password: '1');

      expect(find.bySemanticsLabel('Un número: cumplido'), findsOneWidget);
      expect(find.bySemanticsLabel('Un número: pendiente'), findsNothing);
      semantics.dispose();
    });

    testWidgets('fit at expanded width without overflowing', (tester) async {
      await tester.pumpApp(view(), size: expandedSize);

      expect(tester.takeException(), isNull);
      expect(find.text('Un número'), findsOneWidget);
    });

  });

  group('narrow phones', () {
    // 320 is the narrowest phone in use and 360 the most common. The screen is
    // in Spanish, whose labels are wider than the English ones, so a layout that
    // fits the sign-in screen can still overflow here (the Google button did, by
    // a pixel and a half, at 360).
    for (final width in [320.0, 360.0]) {
      testWidgets('the whole screen fits at ${width.toInt()}px without overflow',
          (tester) async {
        await tester.pumpApp(view(), size: Size(width, 1400));

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('submit availability', () {
    bool submitEnabled(WidgetTester tester) =>
        tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton)).enabled;

    testWidgets('starts disabled', (tester) async {
      await tester.pumpApp(view());

      expect(submitEnabled(tester), isFalse);
    });

    testWidgets('enables once every rule holds', (tester) async {
      await tester.pumpApp(view());

      await fillValidForm(tester);

      expect(submitEnabled(tester), isTrue);
    });

    testWidgets('stays disabled with an invalid email', (tester) async {
      await tester.pumpApp(view());

      await fill(
        tester,
        email: 'ana',
        password: 'Hunter22!',
        confirmation: 'Hunter22!',
      );

      expect(submitEnabled(tester), isFalse);
    });

    for (final entry in {
      'no uppercase letter': 'hunter22!',
      'no number': 'Hunterxx!',
      'no symbol': 'Hunter22x',
    }.entries) {
      testWidgets('stays disabled with a password that has ${entry.key}',
          (tester) async {
        await tester.pumpApp(view());

        await fill(
          tester,
          email: 'ana@example.com',
          password: entry.value,
          confirmation: entry.value,
        );

        expect(submitEnabled(tester), isFalse);
      });
    }

    testWidgets('stays disabled with a short password', (tester) async {
      await tester.pumpApp(view());

      await fill(
        tester,
        email: 'ana@example.com',
        password: 'short',
        confirmation: 'short',
      );

      expect(submitEnabled(tester), isFalse);
    });

    testWidgets('stays disabled when the confirmation differs', (tester) async {
      await tester.pumpApp(view());

      await fill(
        tester,
        email: 'ana@example.com',
        password: 'Hunter22!',
        confirmation: 'Hunter23!',
      );

      expect(submitEnabled(tester), isFalse);
    });

    testWidgets('disables again when a field is spoiled', (tester) async {
      await tester.pumpApp(view());
      await fillValidForm(tester);

      await fill(tester, confirmation: 'hunter2');

      expect(submitEnabled(tester), isFalse);
    });
  });

  group('signing up', () {
    testWidgets('sends the typed details to the controller', (tester) async {
      final repository = _FakeAuthRepository((_) async {});
      await tester.pumpApp(view(), overrides: using(repository));

      await fillValidForm(tester);
      await tester.tap(find.text('Crear cuenta'));
      await tester.pumpAndSettle();

      expect(repository.calls, hasLength(1));
      expect(repository.calls.single.email, 'ana@example.com');
      expect(repository.calls.single.password, 'Hunter22!');
    });

    testWidgets('trims the email but never the password', (tester) async {
      final repository = _FakeAuthRepository((_) async {});
      await tester.pumpApp(view(), overrides: using(repository));

      await fill(
        tester,
        email: '  ana@example.com ',
        password: '  Spaced1!  ',
        confirmation: '  Spaced1!  ',
      );
      await tester.tap(find.text('Crear cuenta'));
      await tester.pumpAndSettle();

      expect(repository.calls.single.email, 'ana@example.com');
      expect(repository.calls.single.password, '  Spaced1!  ');
    });

    testWidgets('does not reach the controller while the form is invalid',
        (tester) async {
      final repository = _FakeAuthRepository((_) async {});
      await tester.pumpApp(view(), overrides: using(repository));
      await fill(
        tester,
        email: 'ana@example.com',
        password: 'Hunter22!',
        confirmation: 'other',
      );

      await tester.tap(find.text('Crear cuenta'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(repository.calls, isEmpty);
    });

    testWidgets('does not call onSignedUp just by being shown', (tester) async {
      var signedUp = 0;
      await tester.pumpApp(
        view(onSignedUp: () => signedUp++),
        overrides: using(_FakeAuthRepository((_) async {})),
      );
      await tester.pumpAndSettle();

      expect(signedUp, isZero);
    });

    testWidgets('calls onSignedUp once the attempt succeeds', (tester) async {
      var signedUp = 0;
      await tester.pumpApp(
        view(onSignedUp: () => signedUp++),
        overrides: using(_FakeAuthRepository((_) async {})),
      );

      await fillValidForm(tester);
      await tester.tap(find.text('Crear cuenta'));
      await tester.pumpAndSettle();

      expect(signedUp, 1);
    });

    testWidgets('waits for the result before calling onSignedUp',
        (tester) async {
      final pending = Completer<void>();
      var signedUp = 0;
      await tester.pumpApp(
        view(onSignedUp: () => signedUp++),
        overrides: using(_FakeAuthRepository((_) => pending.future)),
      );

      await fillValidForm(tester);
      await tester.tap(find.text('Crear cuenta'));
      await tester.pump();

      expect(signedUp, isZero, reason: 'still in flight');

      pending.complete();
      await tester.pumpAndSettle();

      expect(signedUp, 1);
    });

    testWidgets('does not call onSignedUp when the attempt fails',
        (tester) async {
      var signedUp = 0;
      await tester.pumpApp(
        view(onSignedUp: () => signedUp++),
        overrides: using(
          _FakeAuthRepository((_) async => throw const UnknownAuthFailure()),
        ),
      );

      await fillValidForm(tester);
      await tester.tap(find.text('Crear cuenta'));
      await tester.pumpAndSettle();

      expect(signedUp, isZero);
    });

    testWidgets('shows a spinner on the button while the request is in flight',
        (tester) async {
      final pending = Completer<void>();
      await tester.pumpApp(
        view(),
        overrides: using(_FakeAuthRepository((_) => pending.future)),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await fillValidForm(tester);
      await tester.tap(find.text('Crear cuenta'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Crear cuenta'), findsNothing);

      pending.complete();
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Crear cuenta'), findsOneWidget);
    });

    testWidgets('ignores a second tap while the request is in flight',
        (tester) async {
      final pending = Completer<void>();
      final repository = _FakeAuthRepository((_) => pending.future);
      await tester.pumpApp(view(), overrides: using(repository));

      await fillValidForm(tester);
      await tester.tap(find.byType(AppPrimaryButton));
      await tester.pump();
      await tester.tap(find.byType(AppPrimaryButton), warnIfMissed: false);
      await tester.pump();

      expect(repository.calls, hasLength(1));

      pending.complete();
      await tester.pumpAndSettle();
    });

    group('error message', () {
      Future<void> attemptWith(
        WidgetTester tester,
        Future<void> Function(SignUpParams) onSignUp,
      ) async {
        await tester.pumpApp(
          view(),
          overrides: using(_FakeAuthRepository(onSignUp)),
        );
        await fillValidForm(tester);
        await tester.tap(find.text('Crear cuenta'));
        await tester.pumpAndSettle();
      }

      testWidgets('is absent before any attempt', (tester) async {
        await tester.pumpApp(
          view(),
          overrides: using(_FakeAuthRepository((_) async {})),
        );

        expect(find.byIcon(Icons.error_outline), findsNothing);
      });

      testWidgets('says the email already has an account', (tester) async {
        await attemptWith(
          tester,
          (_) async => throw const EmailAlreadyInUseFailure(),
        );

        expect(find.text('Ya existe una cuenta con ese correo.'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('says the server cannot be reached', (tester) async {
        await attemptWith(tester, (_) async => throw const ConnectionFailure());

        expect(
          find.textContaining('No se puede conectar con el servidor'),
          findsOneWidget,
        );
      });

      testWidgets('tells the person to sign in when the session was not kept',
          (tester) async {
        // The account was created, so retrying is not the advice.
        await attemptWith(
          tester,
          (_) async => throw const SessionNotSavedFailure(),
        );

        expect(find.textContaining('Tu cuenta se creó'), findsOneWidget);
        expect(find.textContaining('Inicia sesión para continuar'), findsOneWidget);
      });

      testWidgets('is generic for any other authentication failure',
          (tester) async {
        await attemptWith(tester, (_) async => throw const UnknownAuthFailure());

        expect(find.text('Algo salió mal. Inténtalo de nuevo.'), findsOneWidget);
      });

      testWidgets('is generic, with no internals, for a non-auth error',
          (tester) async {
        // A bug must not leak its message or stack trace onto the screen.
        await attemptWith(tester, (_) async => throw StateError('internal'));

        expect(find.text('Algo salió mal. Inténtalo de nuevo.'), findsOneWidget);
        expect(find.textContaining('internal'), findsNothing);
      });

      testWidgets('goes away when the user tries again', (tester) async {
        final retry = Completer<void>();
        var attempts = 0;
        await tester.pumpApp(
          view(),
          overrides: using(
            _FakeAuthRepository((_) {
              attempts++;
              if (attempts == 1) {
                return Future<void>.error(const EmailAlreadyInUseFailure());
              }
              return retry.future;
            }),
          ),
        );
        await fillValidForm(tester);
        await tester.tap(find.text('Crear cuenta'));
        await tester.pumpAndSettle();
        expect(find.text('Ya existe una cuenta con ese correo.'), findsOneWidget);

        await tester.tap(find.text('Crear cuenta'));
        await tester.pump();

        expect(find.text('Ya existe una cuenta con ese correo.'), findsNothing);

        retry.complete();
        await tester.pumpAndSettle();
      });

      testWidgets('is absent after a successful attempt', (tester) async {
        await attemptWith(tester, (_) async {});

        expect(find.byIcon(Icons.error_outline), findsNothing);
      });
    });
  });

  group('sign-in link', () {
    testWidgets('"Inicia sesión" calls onSignInTapped', (tester) async {
      var taps = 0;
      await tester.pumpApp(view(onSignInTapped: () => taps++));

      await tester.tap(find.text('Inicia sesión'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('does not call onSignInTapped just by being shown',
        (tester) async {
      var taps = 0;
      await tester.pumpApp(view(onSignInTapped: () => taps++));
      await tester.pumpAndSettle();

      expect(taps, isZero);
    });
  });
}
