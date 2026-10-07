import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mounts a widget inside the real app theme at a chosen window size.
///
/// Every widget reads its colours and text styles through the theme, so pumping
/// it under Flutter's default theme would assert against the wrong values. And
/// a responsive screen tested at one width proves nothing (CLAUDE.md section 6).
///
/// Each package keeps its own copy rather than sharing one: a shared helper
/// would need a package of its own, which is more machinery than ~20 lines.
extension PumpApp on WidgetTester {
  /// Pumps [widget] as the home of a themed [MaterialApp].
  Future<void> pumpApp(Widget widget, {Size size = compactSize}) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1;
    addTearDown(view.reset);

    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        // Widgets that ripple (InkWell) need a Material ancestor. In the app
        // the Scaffold provides one; in isolation nothing does.
        home: Material(type: MaterialType.transparency, child: widget),
      ),
    );
  }
}

/// A phone-width window, tall enough that scrollable screens fit without
/// scrolling before a tap.
const compactSize = Size(400, 1400);

/// A desktop-width window.
const expandedSize = Size(1000, 1400);
