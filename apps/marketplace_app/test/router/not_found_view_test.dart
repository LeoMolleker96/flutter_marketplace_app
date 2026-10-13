import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/router/not_found_view.dart';

void main() {
  /// Mounts the view at [size] and returns a counter of "Go to home" taps.
  Future<List<int>> pumpView(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final taps = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: NotFoundView(onGoHome: () => taps.add(1)),
      ),
    );
    return taps;
  }

  const sizes = {'compact': Size(400, 800), 'expanded': Size(1000, 800)};

  for (final MapEntry(key: name, value: size) in sizes.entries) {
    group('at $name width', () {
      testWidgets('shows the fixed copy', (tester) async {
        await pumpView(tester, size);

        expect(find.text('Page not found'), findsOneWidget);
        expect(
          find.text('The page you are looking for does not exist.'),
          findsOneWidget,
        );
        expect(find.text('Go to home'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('keeps the column narrower than the window', (tester) async {
        await pumpView(tester, size);

        final width = tester.getSize(find.byType(AppPrimaryButton)).width;
        expect(width, lessThanOrEqualTo(440));
        expect(width, lessThanOrEqualTo(size.width));
      });

      testWidgets('calls onGoHome when the button is tapped', (tester) async {
        final taps = await pumpView(tester, size);

        await tester.tap(find.text('Go to home'));
        await tester.pump();

        expect(taps, hasLength(1));
      });
    });
  }
}
