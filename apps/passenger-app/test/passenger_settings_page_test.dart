import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/side_menu_and_settings/side_menu_and_settings.dart';

void main() {
  Widget buildTestWidget({VoidCallback? onBack, ValueChanged<String>? onNavigate}) {
    return MaterialApp(
      home: PassengerSettingsPage(
        onBack: onBack,
        onNavigate: onNavigate,
      ),
    );
  }

  testWidgets('PassengerSettingsPage renders Screen 3 with all sections and metered rate box', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify app bar
    expect(find.text('Settings'), findsWidgets);

    // Verify Preferences & Alerts
    expect(find.text('PREFERENCES & ALERTS'), findsOneWidget);
    expect(find.text('Push Notifications'), findsOneWidget);
    expect(find.textContaining('Notifications are off for this app in system settings'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);

    // Verify Help & Legal
    expect(find.text('HELP & LEGAL'), findsOneWidget);
    expect(find.text('FAQs'), findsOneWidget);
    expect(find.text('Terms and conditions'), findsOneWidget);
    expect(find.text('Privacy and data'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);

    // Verify Frequently Asked Questions
    expect(find.text('FREQUENTLY ASKED QUESTIONS'), findsOneWidget);
    expect(find.text('Search help & FAQs...'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Booking'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);

    // Verify expanded metered rate box
    expect(find.text('Lethbridge Metered Taxi Rates (Bylaw 6138)'), findsOneWidget);
    expect(find.text('Base Metered Drop'), findsOneWidget);
    expect(find.text('\$3.80 CAD'), findsOneWidget);
    expect(find.text('Distance Rate'), findsOneWidget);
    expect(find.text('\$1.95 CAD / km'), findsOneWidget);

    // Verify About Bridge City Cabs card
    expect(find.text('ABOUT BRIDGE CITY CABS'), findsOneWidget);
    expect(find.textContaining('326F 10 Street North, Lethbridge'), findsOneWidget);
    expect(find.textContaining('+1 (587) 329-5577'), findsOneWidget);
    expect(find.textContaining('www.bridgecitycabs.ca ↗'), findsOneWidget);

    // Verify action buttons
    expect(find.text('Contact support'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    expect(find.text('Version 1.0.19 (Build 240) • Made in Alberta'), findsOneWidget);
  });
}
