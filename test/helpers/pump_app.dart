import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/core/theme/app_theme.dart';

/// Mounts a widget inside the real app theme at a chosen window size.
///
/// The theme matters: every widget in this project reads its colours and text
/// styles through `context.colors` / `context.textStyles`, so pumping them
/// under Flutter's default theme would assert against the wrong values.
///
/// The size matters just as much — a responsive screen tested at one width
/// proves nothing (CLAUDE.md section 6).
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
        // the Scaffold provides one; in isolation nothing does, so the harness
        // supplies a transparent one rather than each test remembering to.
        home: Material(type: MaterialType.transparency, child: widget),
      ),
    );
  }

  /// Pumps a widget tree that already provides its own routing.
  Future<void> pumpRouter(RouterConfig<Object> config, {Size size = compactSize}) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1;
    addTearDown(view.reset);

    await pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: config),
    );
  }
}

/// A phone-width window. Tall enough that scrollable screens fit without
/// needing to scroll before tapping.
const compactSize = Size(400, 1400);

/// A desktop-width window.
const expandedSize = Size(1000, 1400);
