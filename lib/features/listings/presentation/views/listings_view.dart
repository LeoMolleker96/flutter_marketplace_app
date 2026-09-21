import 'package:flutter/material.dart';
import 'package:marketplace_app/core/widgets/app_text.dart';

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
