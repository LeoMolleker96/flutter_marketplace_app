import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mounts a widget inside the real app theme at a chosen window size.
///
/// See the identical helper in `feature_auth` for why each package keeps its own
/// copy.
extension PumpApp on WidgetTester {
  /// Pumps [widget] as the home of a themed [MaterialApp].
  Future<void> pumpApp(Widget widget, {Size size = compactSize}) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1;
    addTearDown(view.reset);

    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Material(type: MaterialType.transparency, child: widget),
      ),
    );
  }
}

/// A phone-width window.
const compactSize = Size(400, 1400);

/// A desktop-width window.
const expandedSize = Size(1000, 1400);
