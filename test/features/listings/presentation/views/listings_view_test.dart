import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/features/listings/presentation/views/listings_view.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows its placeholder title at compact width', (tester) async {
    await tester.pumpApp(const ListingsView());

    expect(find.text('Listings'), findsOneWidget);
  });

  testWidgets('shows its placeholder title at expanded width', (tester) async {
    await tester.pumpApp(const ListingsView(), size: expandedSize);

    expect(find.text('Listings'), findsOneWidget);
  });
}
