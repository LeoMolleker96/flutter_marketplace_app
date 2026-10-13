import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  // These three widgets exist so screens never hand-write a TextStyle. The
  // tests therefore assert the exact style each one resolves to — if they
  // drifted, every screen would drift with them and nothing else would fail.

  testWidgets('AppTitle uses the display style on onSurface', (tester) async {
    await tester.pumpApp(const AppTitle('Welcome back'));

    final text = tester.widget<Text>(find.text('Welcome back'));

    expect(text.style?.fontSize, AppTypography.displayLgMobile.fontSize);
    expect(text.style?.fontWeight, FontWeight.w800);
    expect(text.style?.color, AppColors.onSurface);
  });

  testWidgets('AppTitle grows to the desktop style from expanded up', (
    tester,
  ) async {
    await tester.pumpApp(const AppTitle('Welcome back'), size: expandedSize);

    final text = tester.widget<Text>(find.text('Welcome back'));

    expect(text.style?.fontSize, AppTypography.displayLg.fontSize);
    expect(text.style?.fontSize, 40);
  });

  testWidgets('AppTitle stays at the mobile style below expanded', (
    tester,
  ) async {
    await tester.pumpApp(const AppTitle('Welcome back'));

    expect(tester.widget<Text>(find.text('Welcome back')).style?.fontSize, 32);
  });

  testWidgets('AppSubtitle uses body on the muted colour', (tester) async {
    await tester.pumpApp(const AppSubtitle('Discover unique finds'));

    final text = tester.widget<Text>(find.text('Discover unique finds'));

    expect(text.style?.fontSize, AppTypography.bodyMd.fontSize);
    expect(text.style?.color, AppColors.onSurfaceVariant);
  });

  testWidgets('AppFootnote uses the smallest body on outline', (tester) async {
    await tester.pumpApp(const AppFootnote('By continuing you agree'));

    final text = tester.widget<Text>(find.text('By continuing you agree'));

    expect(text.style?.fontSize, AppTypography.bodySm.fontSize);
    expect(text.style?.color, AppColors.outline);
  });

  testWidgets('all three centre their text by default', (tester) async {
    await tester.pumpApp(
      const Column(
        children: [AppTitle('a'), AppSubtitle('b'), AppFootnote('c')],
      ),
    );

    for (final label in ['a', 'b', 'c']) {
      expect(tester.widget<Text>(find.text(label)).textAlign, TextAlign.center);
    }
  });

  testWidgets('text alignment can be overridden', (tester) async {
    await tester.pumpApp(const AppTitle('a', textAlign: TextAlign.left));

    expect(tester.widget<Text>(find.text('a')).textAlign, TextAlign.left);
  });
}
