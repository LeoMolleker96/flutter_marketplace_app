import 'package:flutter/widgets.dart';

/// The width thresholds between window size classes, in logical pixels.
///
/// These are the Material 3 window size classes. They describe the **window**
/// the app is drawn in, never the device: a phone in split-screen and a browser
/// resized to 400 px are both compact (CLAUDE.md section 6).
///
/// This is the one place the numbers are written. A widget that needs to
/// branch asks for a [WindowSizeClass] instead of comparing a width, so a raw
/// `600` never appears in a view.
abstract final class Breakpoints {
  /// Where [WindowSizeClass.compact] ends and [WindowSizeClass.medium] begins.
  static const medium = 600.0;

  /// Where [WindowSizeClass.medium] ends and [WindowSizeClass.expanded] begins.
  static const expanded = 840.0;

  /// Where [WindowSizeClass.expanded] ends and [WindowSizeClass.large] begins.
  static const large = 1200.0;

  /// Where [WindowSizeClass.large] ends and [WindowSizeClass.extraLarge]
  /// begins.
  static const extraLarge = 1600.0;
}

/// How much horizontal room the window offers, in Material 3's five steps.
///
/// Views read this to decide what to show and how to space it; view models
/// never do, because resizing the window must not rebuild state or refetch data
/// (CLAUDE.md section 6).
enum WindowSizeClass {
  /// Under 600 px: a phone in portrait or a narrow browser window. Bottom
  /// navigation bar.
  compact,

  /// 600 to 839 px: a tablet in portrait or an unfolded foldable. Navigation
  /// rail.
  medium,

  /// 840 to 1199 px: a tablet in landscape or a small desktop browser.
  /// Navigation rail, list-detail layouts.
  expanded,

  /// 1200 to 1599 px: a large tablet or a desktop browser. Standard
  /// navigation drawer.
  large,

  /// 1600 px and up: a wide desktop browser. Standard navigation drawer, with
  /// the content column constrained.
  extraLarge;

  /// The class a window [width] (in logical pixels) falls into.
  ///
  /// A static method on the enum rather than a free function so it is found
  /// next to the type it returns. Each threshold belongs to the larger class:
  /// exactly 600 is [medium].
  static WindowSizeClass fromWidth(double width) {
    if (width >= Breakpoints.extraLarge) return extraLarge;
    if (width >= Breakpoints.large) return large;
    if (width >= Breakpoints.expanded) return expanded;
    if (width >= Breakpoints.medium) return medium;
    return compact;
  }

  /// Whether this class is [other] or wider.
  ///
  /// Reads better than comparing indices at the call site:
  /// `context.windowSizeClass.isAtLeast(WindowSizeClass.expanded)`.
  bool isAtLeast(WindowSizeClass other) => index >= other.index;
}

/// Reads the current [WindowSizeClass] from a [BuildContext].
extension WindowSizeClassContext on BuildContext {
  /// The size class of the window this context is drawn in.
  ///
  /// Uses `MediaQuery.sizeOf`, so a widget only rebuilds when the size changes,
  /// not on every metric change such as the keyboard opening.
  WindowSizeClass get windowSizeClass =>
      WindowSizeClass.fromWidth(MediaQuery.sizeOf(this).width);
}
