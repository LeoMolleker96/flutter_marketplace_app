import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

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

  group('errorText', () {
    testWidgets('shows nothing by default', (tester) async {
      await tester.pumpApp(
        const AppTextField(
          label: 'Email',
          hintText: 'hint',
          icon: Icons.mail_outline,
        ),
      );

      expect(find.text('Not an email.'), findsNothing);
    });

    testWidgets('shows the message under the field', (tester) async {
      await tester.pumpApp(
        const AppTextField(
          label: 'Email',
          hintText: 'hint',
          icon: Icons.mail_outline,
          errorText: 'Not an email.',
        ),
      );

      expect(find.text('Not an email.'), findsOneWidget);
      // Under the field, not inside it: the field has a fixed height.
      expect(
        tester.getTopLeft(find.text('Not an email.')).dy,
        greaterThanOrEqualTo(tester.getBottomLeft(find.byType(TextField)).dy),
      );
    });

    testWidgets('does not overflow the fixed field height', (tester) async {
      await tester.pumpApp(
        const AppTextField(
          label: 'Email',
          hintText: 'hint',
          icon: Icons.mail_outline,
          errorText: 'Not an email.',
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(TextField)).height, 56);
    });

    testWidgets('takes an error-coloured border', (tester) async {
      await tester.pumpApp(
        const AppTextField(
          label: 'Email',
          hintText: 'hint',
          icon: Icons.mail_outline,
          errorText: 'Not an email.',
        ),
      );

      final border = tester
          .widget<TextField>(find.byType(TextField))
          .decoration!
          .enabledBorder! as OutlineInputBorder;

      expect(border.borderSide.color, AppColors.error);
    });

    testWidgets('is announced to a screen reader when it appears',
        (tester) async {
      await tester.pumpApp(
        const AppTextField(
          label: 'Email',
          hintText: 'hint',
          icon: Icons.mail_outline,
          errorText: 'Not an email.',
        ),
      );

      final liveRegion = find.ancestor(
        of: find.text('Not an email.'),
        matching: find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.liveRegion == true,
        ),
      );

      expect(liveRegion, findsOneWidget);
    });

    testWidgets('goes away when the message is cleared', (tester) async {
      Widget field(String? error) => AppTextField(
            label: 'Email',
            hintText: 'hint',
            icon: Icons.mail_outline,
            errorText: error,
          );

      await tester.pumpApp(field('Not an email.'));
      await tester.pumpApp(field(null));

      expect(find.text('Not an email.'), findsNothing);
    });
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
