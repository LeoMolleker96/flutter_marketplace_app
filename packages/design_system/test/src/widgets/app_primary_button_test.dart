import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

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
      AppPrimaryButton(label: 'Sign In', onPressed: () {}),
    );

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
  });

  testWidgets('omits the icon when asked', (tester) async {
    await tester.pumpApp(
      AppPrimaryButton(label: 'Sign In', onPressed: () {}, icon: null),
    );

    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var taps = 0;

    await tester.pumpApp(
      AppPrimaryButton(label: 'Sign In', onPressed: () => taps++),
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
          label: 'Sign In',
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
        AppPrimaryButton(label: 'Sign In', onPressed: () {}, enabled: false),
      );

      final disabled = _decorationOf(tester);
      expect(disabled.gradient, isNull, reason: 'grey, not a dimmed gradient');
      expect(disabled.color, isNotNull);

      await tester.pumpApp(
        AppPrimaryButton(label: 'Sign In', onPressed: () {}),
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
        AppPrimaryButton(label: 'Sign In', onPressed: () {}, enabled: false),
      );

      expect(find.byType(Opacity), findsNothing);
      expect(
        tester.widget<Text>(find.text('Sign In')).style?.color,
        isNot(AppColors.onPrimary),
      );

      await tester.pumpApp(
        AppPrimaryButton(label: 'Sign In', onPressed: () {}),
      );

      expect(
        tester.widget<Text>(find.text('Sign In')).style?.color,
        AppColors.onPrimary,
      );
    });
  });

  group('loading', () {
    AppPrimaryButton loadingButton({VoidCallback? onPressed}) {
      return AppPrimaryButton(
        label: 'Sign In',
        onPressed: onPressed ?? () {},
        isLoading: true,
      );
    }

    testWidgets('shows a spinner in place of the label and icon',
        (tester) async {
      await tester.pumpApp(loadingButton());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);
      expect(find.byIcon(Icons.arrow_forward), findsNothing);
    });

    testWidgets('shows no spinner when it is not loading', (tester) async {
      await tester.pumpApp(
        AppPrimaryButton(label: 'Sign In', onPressed: () {}),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('ignores taps, so a second press cannot start a second action',
        (tester) async {
      var taps = 0;

      await tester.pumpApp(loadingButton(onPressed: () => taps++));

      await tester.tap(find.byType(AppPrimaryButton), warnIfMissed: false);
      await tester.pump();

      expect(taps, isZero);
    });

    testWidgets('keeps the gradient: in progress is not unavailable',
        (tester) async {
      await tester.pumpApp(loadingButton());

      final decoration = _decorationOf(tester);
      expect(decoration.gradient, isNotNull);
      expect(decoration.color, isNull);
    });

    testWidgets('draws the spinner in the on-primary colour', (tester) async {
      await tester.pumpApp(loadingButton());

      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(spinner.color, AppColors.onPrimary);
    });

    testWidgets('keeps its height, so the layout does not jump',
        (tester) async {
      await tester.pumpApp(
        AppPrimaryButton(label: 'Sign In', onPressed: () {}),
      );
      final idleHeight = tester.getSize(find.byType(AppPrimaryButton)).height;

      await tester.pumpApp(loadingButton());

      expect(tester.getSize(find.byType(AppPrimaryButton)).height, idleHeight);
    });
  });
}