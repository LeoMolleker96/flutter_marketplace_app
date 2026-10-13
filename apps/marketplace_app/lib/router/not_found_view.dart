import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// The screen shown when the address matches no route.
///
/// Its copy is fixed on purpose. go_router's own error page prints the
/// requested location and the exception, and that location comes from the URL,
/// which anyone can craft: a link such as `/Your%20account%20is%20suspended`
/// would put someone else's wording inside the app, which is phishing. This view
/// is never handed the location, the exception or any part of the URL, so it
/// cannot show them.
///
/// It lives in the app shell and takes [onGoHome] because only the shell knows
/// where home is (CLAUDE.md section 4); the view stays a plain screen with no
/// router dependency, like the features' screens.
class NotFoundView extends StatelessWidget {
  /// Creates the not-found screen.
  const NotFoundView({required this.onGoHome, super.key});

  /// Called when the user taps "Go to home"; the shell decides where that is.
  final VoidCallback onGoHome;

  /// Same column width the authentication screens use, so a form-sized column
  /// never spans a wide browser window (CLAUDE.md section 6).
  static const _contentMaxWidth = 440.0;

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
                  const AppTitle('Page not found'),
                  const SizedBox(height: AppSpacing.xs),
                  const AppSubtitle(
                    'The page you are looking for does not exist.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(label: 'Go to home', onPressed: onGoHome),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
