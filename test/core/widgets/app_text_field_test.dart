import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/core/widgets/app_text_field.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('renders the label, hint and leading icon', (tester) async {
    await tester.pumpApp(
      const AppTextField(
        label: 'Email or Username',
        hintText: 'name@example.com',
        icon: Icons.mail_outline,
      ),
    );

    expect(find.text('Email or Username'), findsOneWidget);
    expect(find.text('name@example.com'), findsOneWidget);
    expect(find.byIcon(Icons.mail_outline), findsOneWidget);
  });

  testWidgets('shows a labelAction when given one', (tester) async {
    await tester.pumpApp(
      const AppTextField(
        label: 'Password',
        hintText: '••••••••',
        icon: Icons.lock_outline,
        labelAction: Text('Forgot password?'),
      ),
    );

    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('writes typed text to its controller', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpApp(
      AppTextField(
        label: 'Email',
        hintText: 'hint',
        icon: Icons.mail_outline,
        controller: controller,
      ),
    );

    await tester.enterText(find.byType(TextField), 'ana@example.com');

    expect(controller.text, 'ana@example.com');
  });

  group('obscurable', () {
    testWidgets('a plain field has no visibility toggle', (tester) async {
      await tester.pumpApp(
        const AppTextField(
          label: 'Email',
          hintText: 'hint',
          icon: Icons.mail_outline,
        ),
      );

      expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isFalse);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('starts hidden and toggles both ways', (tester) async {
      await tester.pumpApp(
        const AppTextField(
          label: 'Password',
          hintText: '••••••••',
          icon: Icons.lock_outline,
          obscurable: true,
        ),
      );

      TextField field() => tester.widget<TextField>(find.byType(TextField));

      expect(field().obscureText, isTrue);
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      expect(field().obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(field().obscureText, isTrue);
    });
  });
}
