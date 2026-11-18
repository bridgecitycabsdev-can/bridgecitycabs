import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/offer/offer_page.dart';

void main() {
  testWidgets('OfferPage loads and renders DriverRequestPage properly', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: OfferPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('New ride request'), findsOneWidget);
    expect(find.text('ACCEPT RIDE'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);
  });
}
