import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/core/theme/app_colors.dart';
import 'package:marketplace_app/core/widgets/app_primary_button.dart';

import '../../helpers/pump_app.dart';

/// The button's own decoration — the outermost one it builds.
BoxDecoration _decorationOf(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(AppPrimaryButton),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );

  return box.decoration as BoxDecoration;
}

void main() {
  testWidgets('renders its label and the default trailing arrow',
      (tester) async {
    await tester.pumpApp(
      AppPrimaryButton(label: 'Log In', onPressed: () {}),
    );

    expect(find.text('Log In'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
  });

  testWidgets('omits the icon when asked', (tester) async {
    await tester.pumpApp(
      AppPrimaryButton(label: 'Log In', onPressed: () {}, icon: null),
    );

    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var taps = 0;

    await tester.pumpApp(
      AppPrimaryButton(label: 'Log In', onPressed: () => taps++),
    );

    await tester.tap(find.byType(AppPrimaryButton));
    await tester.pump();

    expect(taps, 1);
  });

  group('disabled', () {
    testWidgets('holds a callback but refuses to fire it', (tester) async {
      // onPressed is always supplied; `enabled` alone decides whether a tap
      // reaches it.
      var taps = 0;

      await tester.pumpApp(
        AppPrimaryButton(
          label: 'Log In',
          onPressed: () => taps++,
          enabled: false,
        ),
      );

      await tester.tap(find.byType(AppPrimaryButton), warnIfMissed: false);
      await tester.pump();

      expect(taps, isZero);
    });

    testWidgets('drops the gradient for a flat grey fill', (tester) async {
      await tester.pumpApp(
        AppPrimaryButton(label: 'Log In', onPressed: () {}, enabled: false),
      );

      final disabled = _decorationOf(tester);
      expect(disabled.gradient, isNull, reason: 'grey, not a dimmed gradient');
      expect(disabled.color, isNotNull);

      await tester.pumpApp(
        AppPrimaryButton(label: 'Log In', onPressed: () {}),
      );

      final active = _decorationOf(tester);
      expect(active.gradient, isNotNull);
      expect(active.color, isNull);
    });

    testWidgets('mutes the label instead of fading the whole widget',
        (tester) async {
      // No Opacity anywhere: it forces a saveLayer for every frame the widget
      // is alive, and dimming the gradient reads as washed out rather than
      // unavailable.
      await tester.pumpApp(
        AppPrimaryButton(label: 'Log In', onPressed: () {}, enabled: false),
      );

      expect(find.byType(Opacity), findsNothing);
      expect(
        tester.widget<Text>(find.text('Log In')).style?.color,
        isNot(AppColors.onPrimary),
      );

      await tester.pumpApp(
        AppPrimaryButton(label: 'Log In', onPressed: () {}),
      );

      expect(
        tester.widget<Text>(find.text('Log In')).style?.color,
        AppColors.onPrimary,
      );
    });
  });
}
