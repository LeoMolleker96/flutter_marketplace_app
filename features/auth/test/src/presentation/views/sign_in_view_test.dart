import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_auth/src/domain/failures/auth_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// A repository whose `signIn` answers through [onSignIn], so each test
/// supplies the behaviour while mocktail remembers what it was asked to do.
_MockAuthRepository _repositoryAnswering(
  Future<void> Function(SignInParams params) onSignIn,
) {
  final repository = _MockAuthRepository();
  when(() => repository.signIn(any())).thenAnswer(
    (invocation) =>
        onSignIn(invocation.positionalArguments.single as SignInParams),
  );
  return repository;
}

/// What the repository was asked to sign in with, in order.
///
/// Fails if it was never asked; use `verifyNever` to assert that.
List<SignInParams> _signInCalls(_MockAuthRepository repository) =>
    verify(() => repository.signIn(captureAny())).captured.cast<SignInParams>();

void main() {
  setUpAll(() {
    // `any()` needs a stand-in value for the parameter type it matches.
    registerFallbackValue(
      const SignInParams(email: 'ana', password: 'hunter22'),
    );
  });

  group('layout', () {
    testWidgets('renders every section at compact width', (tester) async {
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
      );

      expect(find.text('Welcome back'), findsOneWidget);
      expect(
        find.text('Discover unique finds and connect with trusted sellers'),
        findsOneWidget,
      );
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Face ID'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Or Continue With'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
      expect(find.textContaining('Terms of Service'), findsOneWidget);
    });

    testWidgets('renders every section at expanded width', (tester) async {
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
        size: expandedSize,
      );

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('caps the content column on a wide window', (tester) async {
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
        size: expandedSize,
      );

      // Without the cap the card would stretch to the full 1000px, which is
      // the classic way a mobile-first form breaks on the web.
      final cardWidth = tester.getSize(find.byType(TextField).first).width;

      expect(cardWidth, lessThanOrEqualTo(440));
    });

    testWidgets('scrolls rather than overflowing on a short window', (
      tester,
    ) async {
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
        size: const Size(400, 600),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('sign up link', () {
    testWidgets('calls onSignUpTapped when tapped', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () => taps++),
      );

      await tester.tap(find.text('Sign up'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('does not call onSignUpTapped just by being shown', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () => taps++),
      );
      await tester.pumpAndSettle();

      expect(taps, isZero);
    });
  });

  group('remember me', () {
    testWidgets('starts unchecked and toggles both ways', (tester) async {
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
      );

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
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
      );

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
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
      );

      expect(submitEnabled(tester), isFalse);
    });

    testWidgets('stays disabled with only the email filled', (tester) async {
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
      );

      await fill(tester, email: 'ana@example.com');

      expect(submitEnabled(tester), isFalse);
    });

    testWidgets('stays disabled with only the password filled', (tester) async {
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
      );

      await fill(tester, password: 'hunter22');

      expect(submitEnabled(tester), isFalse);
    });

    testWidgets('ignores an email of nothing but whitespace', (tester) async {
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
      );

      await fill(tester, email: '   ', password: 'hunter22');

      expect(submitEnabled(tester), isFalse);
    });

    testWidgets('enables once both fields have content', (tester) async {
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
      );

      await fill(tester, email: 'ana@example.com', password: 'hunter22');

      expect(submitEnabled(tester), isTrue);
    });

    testWidgets('disables again when a field is cleared', (tester) async {
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
      );

      await fill(tester, email: 'ana@example.com', password: 'hunter22');
      expect(submitEnabled(tester), isTrue);

      await fill(tester, email: '');

      expect(submitEnabled(tester), isFalse);
    });
  });

  group('email validation', () {
    bool submitEnabled(WidgetTester tester) =>
        tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton)).enabled;

    Future<void> fill(
      WidgetTester tester,
      String email,
      String password,
    ) async {
      await tester.enterText(find.byType(TextField).first, email);
      await tester.enterText(find.byType(TextField).last, password);
      await tester.pump();
    }

    const message = 'Enter a valid email address.';

    for (final entry in {
      'compact': compactSize,
      'expanded': expandedSize,
    }.entries) {
      group('at ${entry.key} width', () {
        testWidgets('says nothing about an untouched field', (tester) async {
          await tester.pumpApp(
            SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
            size: entry.value,
          );

          expect(find.text(message), findsNothing);
        });

        testWidgets('flags an invalid email and keeps the button disabled', (
          tester,
        ) async {
          await tester.pumpApp(
            SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
            size: entry.value,
          );

          await fill(tester, 'ana@example', 'hunter22');

          expect(find.text(message), findsOneWidget);
          expect(submitEnabled(tester), isFalse);
        });

        testWidgets('clears the message and enables the button once valid', (
          tester,
        ) async {
          await tester.pumpApp(
            SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
            size: entry.value,
          );

          await fill(tester, 'ana', 'hunter22');
          expect(find.text(message), findsOneWidget);

          await fill(tester, 'ana@example.com', 'hunter22');

          expect(find.text(message), findsNothing);
          expect(submitEnabled(tester), isTrue);
        });

        testWidgets('submits the trimmed email', (tester) async {
          final repository = _repositoryAnswering((_) async {});
          await tester.pumpApp(
            SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
            overrides: [authRepositoryProvider.overrideWithValue(repository)],
            size: entry.value,
          );

          await fill(tester, '  ana@example.com ', 'hunter22');
          await tester.tap(find.text('Sign In'));
          await tester.pumpAndSettle();

          final calls = _signInCalls(repository);
          expect(calls.single.email, 'ana@example.com');
        });
      });
    }
  });

  group('signing in', () {
    Future<void> fillCredentials(
      WidgetTester tester, {
      String email = 'ana@example.com',
      String password = 'hunter22',
    }) async {
      await tester.enterText(find.byType(TextField).first, email);
      await tester.enterText(find.byType(TextField).last, password);
      await tester.pump();
    }

    List<Override> using(AuthRepository repository) => [
      authRepositoryProvider.overrideWithValue(repository),
    ];

    testWidgets('sends the typed credentials to the controller', (
      tester,
    ) async {
      final repository = _repositoryAnswering((_) async {});
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
        overrides: using(repository),
      );

      await fillCredentials(tester);
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      final calls = _signInCalls(repository);
      expect(calls, hasLength(1));
      expect(calls.single.email, 'ana@example.com');
      expect(calls.single.password, 'hunter22');
    });

    testWidgets('trims the email but never the password', (tester) async {
      final repository = _repositoryAnswering((_) async {});
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
        overrides: using(repository),
      );

      await fillCredentials(
        tester,
        email: '  ana@example.com ',
        password: '  spaced  ',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      final calls = _signInCalls(repository);
      expect(calls.single.email, 'ana@example.com');
      expect(calls.single.password, '  spaced  ');
    });

    testWidgets('does not reach the controller while the form is incomplete', (
      tester,
    ) async {
      final repository = _repositoryAnswering((_) async {});
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
        overrides: using(repository),
      );

      await tester.tap(find.text('Sign In'), warnIfMissed: false);
      await tester.pumpAndSettle();

      verifyNever(() => repository.signIn(any()));
    });

    testWidgets('does not call onSignedIn just by being shown', (tester) async {
      // The controller starts in an "idle" data state; that is not a success.
      var signedIn = 0;
      await tester.pumpApp(
        SignInView(onSignedIn: () => signedIn++, onSignUpTapped: () {}),
        overrides: using(_repositoryAnswering((_) async {})),
      );
      await tester.pumpAndSettle();

      expect(signedIn, isZero);
    });

    testWidgets('calls onSignedIn once the attempt succeeds', (tester) async {
      var signedIn = 0;
      await tester.pumpApp(
        SignInView(onSignedIn: () => signedIn++, onSignUpTapped: () {}),
        overrides: using(_repositoryAnswering((_) async {})),
      );

      await fillCredentials(tester);
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(signedIn, 1);
    });

    testWidgets('waits for the result before calling onSignedIn', (
      tester,
    ) async {
      final pending = Completer<void>();
      var signedIn = 0;
      await tester.pumpApp(
        SignInView(onSignedIn: () => signedIn++, onSignUpTapped: () {}),
        overrides: using(_repositoryAnswering((_) => pending.future)),
      );

      await fillCredentials(tester);
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(signedIn, isZero, reason: 'still in flight');

      pending.complete();
      await tester.pumpAndSettle();

      expect(signedIn, 1);
    });

    testWidgets('does not call onSignedIn when the attempt fails', (
      tester,
    ) async {
      var signedIn = 0;
      await tester.pumpApp(
        SignInView(onSignedIn: () => signedIn++, onSignUpTapped: () {}),
        overrides: using(
          _repositoryAnswering((_) async => throw StateError('rejected')),
        ),
      );

      await fillCredentials(tester);
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(signedIn, isZero);
    });

    testWidgets('a retry after a failure can still succeed', (tester) async {
      var attempts = 0;
      var signedIn = 0;
      await tester.pumpApp(
        SignInView(onSignedIn: () => signedIn++, onSignUpTapped: () {}),
        overrides: using(
          _repositoryAnswering((_) async {
            attempts++;
            if (attempts == 1) throw StateError('first attempt fails');
          }),
        ),
      );

      await fillCredentials(tester);
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(signedIn, isZero);

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(signedIn, 1);
    });

    testWidgets(
      'shows a spinner on the button while the request is in flight',
      (tester) async {
        final pending = Completer<void>();
        await tester.pumpApp(
          SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
          overrides: using(_repositoryAnswering((_) => pending.future)),
        );
        expect(find.byType(CircularProgressIndicator), findsNothing);

        await fillCredentials(tester);
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Sign In'), findsNothing);

        pending.complete();
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Sign In'), findsOneWidget);
      },
    );

    testWidgets('ignores a second tap while the request is in flight', (
      tester,
    ) async {
      // The spinner is not only cosmetic: pressing again must not start a
      // second request.
      final pending = Completer<void>();
      final repository = _repositoryAnswering((_) => pending.future);
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
        overrides: using(repository),
      );

      await fillCredentials(tester);
      await tester.tap(find.byType(AppPrimaryButton));
      await tester.pump();
      await tester.tap(find.byType(AppPrimaryButton), warnIfMissed: false);
      await tester.pump();

      final calls = _signInCalls(repository);
      expect(calls, hasLength(1));

      pending.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('puts the label back after a failed attempt', (tester) async {
      await tester.pumpApp(
        SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
        overrides: using(
          _repositoryAnswering((_) async => throw StateError('rejected')),
        ),
      );

      await fillCredentials(tester);
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Sign In'), findsOneWidget);
    });

    group('error message', () {
      Future<void> attemptWith(
        WidgetTester tester,
        Future<void> Function(SignInParams) onSignIn, {
        Size size = compactSize,
      }) async {
        await tester.pumpApp(
          SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
          overrides: using(_repositoryAnswering(onSignIn)),
          size: size,
        );
        await fillCredentials(tester);
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();
      }

      testWidgets('is absent before any attempt', (tester) async {
        await tester.pumpApp(
          SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
          overrides: using(_repositoryAnswering((_) async {})),
        );

        expect(find.byIcon(Icons.error_outline), findsNothing);
      });

      testWidgets('says the credentials are wrong', (tester) async {
        await attemptWith(
          tester,
          (_) async => throw const InvalidCredentialsFailure(),
        );

        expect(find.text('Incorrect email or password.'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      for (final entry in {
        'compact': compactSize,
        'expanded': expandedSize,
      }.entries) {
        testWidgets('says the credentials are wrong at ${entry.key} width', (
          tester,
        ) async {
          await attemptWith(
            tester,
            (_) async => throw const InvalidCredentialsFailure(),
            size: entry.value,
          );

          expect(find.text('Incorrect email or password.'), findsOneWidget);
        });

        testWidgets('says the request was malformed at ${entry.key} width', (
          tester,
        ) async {
          await attemptWith(
            tester,
            (_) async => throw const InvalidRequestFailure(),
            size: entry.value,
          );

          expect(
            find.text('Please check the details you entered and try again.'),
            findsOneWidget,
          );
        });
      }

      testWidgets('says the server cannot be reached', (tester) async {
        await attemptWith(tester, (_) async => throw const ConnectionFailure());

        expect(
          find.text(
            "Can't reach the server. Check your connection and try again.",
          ),
          findsOneWidget,
        );
      });

      testWidgets('says the device could not keep the session', (tester) async {
        await attemptWith(
          tester,
          (_) async => throw const SessionNotSavedFailure(),
        );

        expect(
          find.textContaining("couldn't keep your session"),
          findsOneWidget,
        );
      });

      testWidgets('is generic for any other authentication failure', (
        tester,
      ) async {
        await attemptWith(
          tester,
          (_) async => throw const UnknownAuthFailure(),
        );

        expect(
          find.text('Something went wrong. Please try again.'),
          findsOneWidget,
        );
      });

      testWidgets('is generic, with no internals, for a non-auth error', (
        tester,
      ) async {
        // A bug must not leak its message or stack trace onto the screen.
        await attemptWith(tester, (_) async => throw StateError('internal'));

        expect(
          find.text('Something went wrong. Please try again.'),
          findsOneWidget,
        );
        expect(find.textContaining('internal'), findsNothing);
      });

      testWidgets('goes away when the user tries again', (tester) async {
        final retry = Completer<void>();
        var attempts = 0;
        await tester.pumpApp(
          SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
          overrides: using(
            _repositoryAnswering((_) {
              attempts++;
              if (attempts == 1) {
                return Future<void>.error(const InvalidCredentialsFailure());
              }
              return retry.future;
            }),
          ),
        );

        await fillCredentials(tester);
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();
        expect(find.text('Incorrect email or password.'), findsOneWidget);

        await tester.tap(find.text('Sign In'));
        await tester.pump();

        expect(find.text('Incorrect email or password.'), findsNothing);

        retry.complete();
        await tester.pumpAndSettle();
      });

      testWidgets('is absent after a successful attempt', (tester) async {
        await attemptWith(tester, (_) async {});

        expect(find.byIcon(Icons.error_outline), findsNothing);
      });
    });
  });

  group('keyboard and autofill', () {
    List<Override> using(AuthRepository repository) => [
      authRepositoryProvider.overrideWithValue(repository),
    ];

    Finder emailField() => find.byType(TextField).first;
    Finder passwordField() => find.byType(TextField).last;

    bool hasFocus(WidgetTester tester, Finder field) => tester
        .widget<EditableText>(
          find.descendant(of: field, matching: find.byType(EditableText)),
        )
        .focusNode
        .hasFocus;

    Future<void> fill(
      WidgetTester tester, {
      String email = 'ana@example.com',
      String password = 'hunter22',
    }) async {
      await tester.enterText(emailField(), email);
      await tester.enterText(passwordField(), password);
      await tester.pump();
    }

    for (final entry in {
      'compact': compactSize,
      'expanded': expandedSize,
    }.entries) {
      group('at ${entry.key} width', () {
        Future<_MockAuthRepository> pump(WidgetTester tester) async {
          final repository = _repositoryAnswering((_) async {});
          await tester.pumpApp(
            SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
            overrides: using(repository),
            size: entry.value,
          );
          return repository;
        }

        testWidgets('the fields carry the autofill hints', (tester) async {
          await pump(tester);

          expect(tester.widget<TextField>(emailField()).autofillHints, [
            AutofillHints.email,
            AutofillHints.username,
          ]);
          expect(tester.widget<TextField>(passwordField()).autofillHints, [
            AutofillHints.password,
          ]);
          expect(find.byType(AutofillGroup), findsWidgets);
        });

        testWidgets('caps the email at 254 and the password at 128', (
          tester,
        ) async {
          await pump(tester);

          await tester.enterText(emailField(), 'a' * 300);
          await tester.enterText(passwordField(), 'b' * 300);
          await tester.pump();

          expect(
            tester.widget<TextField>(emailField()).controller!.text,
            hasLength(254),
          );
          expect(
            tester.widget<TextField>(passwordField()).controller!.text,
            hasLength(128),
          );
        });

        testWidgets('next on the email moves focus to the password', (
          tester,
        ) async {
          await pump(tester);

          await tester.tap(emailField());
          await tester.pump();
          expect(hasFocus(tester, emailField()), isTrue);

          await tester.testTextInput.receiveAction(TextInputAction.next);
          await tester.pump();

          expect(hasFocus(tester, passwordField()), isTrue);
          expect(hasFocus(tester, emailField()), isFalse);
        });

        testWidgets('done on the password submits a valid form once', (
          tester,
        ) async {
          final repository = await pump(tester);

          await fill(tester);
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

          final calls = _signInCalls(repository);
          expect(calls, hasLength(1));
          expect(calls.single.email, 'ana@example.com');
          expect(calls.single.password, 'hunter22');
        });

        testWidgets('done submits nothing with an invalid email', (
          tester,
        ) async {
          final repository = await pump(tester);

          await fill(tester, email: 'ana@example');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

          verifyNever(() => repository.signIn(any()));
        });

        testWidgets('done submits nothing with an empty password', (
          tester,
        ) async {
          final repository = await pump(tester);

          await fill(tester, password: '');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

          verifyNever(() => repository.signIn(any()));
        });

        testWidgets('done while a request is in flight submits nothing more', (
          tester,
        ) async {
          final pending = Completer<void>();
          final repository = _repositoryAnswering((_) => pending.future);
          await tester.pumpApp(
            SignInView(onSignedIn: () {}, onSignUpTapped: () {}),
            overrides: using(repository),
            size: entry.value,
          );

          await fill(tester);
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();

          // Done unfocused the field; focus it again and press Enter anew.
          await tester.tap(passwordField());
          await tester.pump();
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();

          expect(_signInCalls(repository), hasLength(1));

          pending.complete();
          await tester.pumpAndSettle();
        });
      });
    }
  });
}
