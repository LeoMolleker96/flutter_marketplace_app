import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WindowSizeClass.fromWidth', () {
    const cases = <(double, WindowSizeClass)>[
      (0, WindowSizeClass.compact),
      (599.9, WindowSizeClass.compact),
      (600, WindowSizeClass.medium),
      (839.9, WindowSizeClass.medium),
      (840, WindowSizeClass.expanded),
      (1199.9, WindowSizeClass.expanded),
      (1200, WindowSizeClass.large),
      (1599.9, WindowSizeClass.large),
      (1600, WindowSizeClass.extraLarge),
      (2400, WindowSizeClass.extraLarge),
    ];

    for (final (width, expected) in cases) {
      test('$width is $expected', () {
        expect(WindowSizeClass.fromWidth(width), expected);
      });
    }
  });

  test('the Breakpoints constants are the Material 3 thresholds', () {
    expect(Breakpoints.medium, 600);
    expect(Breakpoints.expanded, 840);
    expect(Breakpoints.large, 1200);
    expect(Breakpoints.extraLarge, 1600);
  });

  group('isAtLeast', () {
    test('is true for the same class and for any wider one', () {
      expect(
        WindowSizeClass.expanded.isAtLeast(WindowSizeClass.expanded),
        isTrue,
      );
      expect(WindowSizeClass.large.isAtLeast(WindowSizeClass.expanded), isTrue);
      expect(
        WindowSizeClass.extraLarge.isAtLeast(WindowSizeClass.compact),
        isTrue,
      );
    });

    test('is false for a narrower class', () {
      expect(
        WindowSizeClass.compact.isAtLeast(WindowSizeClass.medium),
        isFalse,
      );
      expect(
        WindowSizeClass.medium.isAtLeast(WindowSizeClass.expanded),
        isFalse,
      );
    });
  });

  group('BuildContext.windowSizeClass', () {
    Future<WindowSizeClass> classAt(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      late WindowSizeClass result;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: MediaQueryData.fromView(tester.view),
            child: Builder(
              builder: (context) {
                result = context.windowSizeClass;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      return result;
    }

    testWidgets('is compact in a phone-width window', (tester) async {
      expect(
        await classAt(tester, const Size(400, 800)),
        WindowSizeClass.compact,
      );
    });

    testWidgets('is expanded in a small desktop window', (tester) async {
      expect(
        await classAt(tester, const Size(1000, 800)),
        WindowSizeClass.expanded,
      );
    });

    testWidgets('is extra-large in a wide desktop window', (tester) async {
      expect(
        await classAt(tester, const Size(1920, 1080)),
        WindowSizeClass.extraLarge,
      );
    });
  });
}
