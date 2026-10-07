import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Placeholder for the listings feed.
///
/// Exists so the sign-in flow has somewhere to land; the feature itself comes
/// later.
class ListingsView extends StatelessWidget {
  /// Creates the listings screen.
  const ListingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: AppTitle('Listings')),
    );
  }
}
