import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'brand_mark.dart';

/// The frame every authentication screen shares: the logo, a title and subtitle,
/// then the screen's own content.
///
/// The content column is capped and centred so a form stays readable when the
/// window is a desktop browser rather than a phone (CLAUDE.md section 6), and
/// the whole thing scrolls so a short window never overflows. Keeping that here
/// means each screen only says what is on it.
class AuthLayout extends StatelessWidget {
  /// Creates the frame around [children].
  const AuthLayout({
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });

  /// The screen's heading.
  final String title;

  /// The line under the heading.
  final String subtitle;

  /// What the screen shows below the heading.
  final List<Widget> children;

  static const _contentMaxWidth = 440.0;
  static const _subtitleMaxWidth = 280.0;

  @override
  Widget build(BuildContext context) {
    final isWide = context.windowSizeClass.isAtLeast(WindowSizeClass.expanded);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? AppSpacing.margin : AppSpacing.marginMobile,
              vertical: AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: BrandMark()),
                  const SizedBox(height: AppSpacing.md),
                  AppTitle(title),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _subtitleMaxWidth,
                      ),
                      child: AppSubtitle(subtitle),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
