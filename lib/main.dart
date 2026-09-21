import 'package:flutter/material.dart';
import 'package:marketplace_app/core/router/app_router.dart';
import 'package:marketplace_app/core/theme/app_theme.dart';

void main() {
  runApp(const MarketplaceApp());
}

/// Application root.
///
/// Orientation is deliberately not locked: doing so letterboxes foldables and
/// breaks Android's large-screen requirements (CLAUDE.md section 6).
class MarketplaceApp extends StatelessWidget {
  /// Creates the app.
  const MarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Marketplace',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
