import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/core/widgets/app_checkbox.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('shows no check mark when unchecked', (tester) async {
    await tester.pumpApp(
      AppCheckbox(value: false, onChanged: (_) {}, label: 'Remember me'),
    );

    expect(find.text('Remember me'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('shows a check mark when checked', (tester) async {
    await tester.pumpApp(
      AppCheckbox(value: true, onChanged: (_) {}, label: 'Remember me'),
    );

    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('reports the negated value when tapped', (tester) async {
    bool? reported;

    await tester.pumpApp(
      AppCheckbox(
        value: false,
        onChanged: (value) => reported = value,
        label: 'Remember me',
      ),
    );

    await tester.tap(find.byType(AppCheckbox));
    await tester.pump();

    expect(reported, isTrue);
  });

  testWidgets('reports false when tapped while checked', (tester) async {
    bool? reported;

    await tester.pumpApp(
      AppCheckbox(
        value: true,
        onChanged: (value) => reported = value,
        label: 'Remember me',
      ),
    );

    await tester.tap(find.byType(AppCheckbox));
    await tester.pump();

    expect(reported, isFalse);
  });

  testWidgets('the label is part of the tap target, not just the box',
      (tester) async {
    // A 20px box is an uncomfortably small target; the whole row is meant to
    // be tappable, so the label is tested explicitly.
    bool? reported;

    await tester.pumpApp(
      AppCheckbox(
        value: false,
        onChanged: (value) => reported = value,
        label: 'Remember me',
      ),
    );

    await tester.tap(find.text('Remember me'));
    await tester.pump();

    expect(reported, isTrue);
  });

  testWidgets('is controlled — a tap alone does not change what it shows',
      (tester) async {
    await tester.pumpApp(
      AppCheckbox(value: false, onChanged: (_) {}, label: 'Remember me'),
    );

    await tester.tap(find.byType(AppCheckbox));
    await tester.pump();

    expect(find.byIcon(Icons.check), findsNothing);
  });
}
