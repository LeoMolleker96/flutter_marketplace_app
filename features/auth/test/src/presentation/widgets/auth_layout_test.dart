import 'package:design_system/design_system.dart';
import 'package:feature_auth/src/presentation/widgets/auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const layout = AuthLayout(
    title: 'Welcome back',
    subtitle: 'Sign in to continue',
    children: [Text('content')],
  );

  EdgeInsets scrollPadding(WidgetTester tester) => tester
      .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
      .padding!
      .resolve(TextDirection.ltr);

  testWidgets('uses the mobile side margin at compact width', (tester) async {
    await tester.pumpApp(layout);

    final padding = scrollPadding(tester);
    expect(padding.left, AppSpacing.marginMobile);
    expect(padding.right, AppSpacing.marginMobile);
    expect(padding.left, 16);
  });

  testWidgets('uses the wider side margin at expanded width', (tester) async {
    await tester.pumpApp(layout, size: expandedSize);

    final padding = scrollPadding(tester);
    expect(padding.left, AppSpacing.margin);
    expect(padding.right, AppSpacing.margin);
    expect(padding.left, 24);
  });

  testWidgets('shows its heading and content at both widths', (tester) async {
    for (final size in [compactSize, expandedSize]) {
      await tester.pumpApp(layout, size: size);

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.text('content'), findsOneWidget);
    }
  });
}
