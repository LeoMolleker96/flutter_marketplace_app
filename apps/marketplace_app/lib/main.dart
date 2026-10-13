import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketplace_app/di/app_overrides.dart';
import 'package:marketplace_app/di/dio_provider.dart';
import 'package:marketplace_app/router/app_router.dart';

void main() {
  // Fail fast: providers are lazy (keepAlive controls how long a provider
  // lives, not when it is created), so without this call a misconfigured
  // API_BASE_URL would only surface on the first sign-in.
  resolveApiBaseUrl();

  // ProviderScope holds every provider's state for the whole app. It is the
  // only one, at the root: Riverpod's counterpart to wrapping the tree in
  // BlocProviders, except one scope serves everything. The overrides are where
  // the features' abstract seams get their real implementations.
  runApp(ProviderScope(overrides: appOverrides(), child: const MarketplaceApp()));
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
