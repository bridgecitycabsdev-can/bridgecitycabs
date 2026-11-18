import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/side_menu_and_settings/side_menu_and_settings.dart';

void main() {
  Widget buildTestWidget({VoidCallback? onDismiss, ValueChanged<String>? onNavigate}) {
    return MaterialApp(
      home: SideMenuPage(
        onDismiss: onDismiss,
        onNavigate: onNavigate,
      ),
    );
  }

  testWidgets('SideMenuPage renders Grid View (Screen 1) with profile and cards', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify header
    expect(find.text('Bridge City Cabs'), findsOneWidget);
    expect(find.text('Lethbridge Transit'), findsOneWidget);
    expect(find.text('Passenger'), findsOneWidget);

    // Verify profile
    expect(find.text('Marcus Vance'), findsOneWidget);
    expect(find.text('+1 (403) ••• ••17'), findsOneWidget);

    // Verify grid items
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Trips'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Payment methods'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
    expect(find.text('Safety'), findsOneWidget);

    // Verify settings tile & follow us
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Follow us'), findsOneWidget);
    expect(find.text('Lethbridge community'), findsOneWidget);

    // Verify dismiss button
    expect(find.text('DISMISS'), findsOneWidget);
  });

  testWidgets('SideMenuPage switches to List View and Live Trip Active (Screen 2)', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap QA Rig chip "3. Live Trip Active"
    final liveTripChip = find.text('3. Live Trip Active');
    expect(liveTripChip, findsOneWidget);
    await tester.tap(liveTripChip);
    await tester.pumpAndSettle();

    // Verify live trip banner
    expect(find.textContaining('Trip in progress'), findsOneWidget);
    expect(find.textContaining('Camry SE (Marcus V.)'), findsOneWidget);

    // Verify Clara Henderson profile
    expect(find.text('Clara Henderson'), findsOneWidget);
    expect(find.text('+1 (403) 555-0198'), findsOneWidget);

    // Verify list items
    expect(find.text('Live Trip Tracking'), findsOneWidget);
    expect(find.textContaining('Arriving in'), findsOneWidget);
    expect(find.text('Your Trips'), findsOneWidget);
    expect(find.text('Saved Locations'), findsOneWidget);
    expect(find.text('Safety & Dispatch'), findsOneWidget);
    expect(find.text('Help & Lost Property'), findsOneWidget);

    // Verify locked logout
    expect(find.text('Finish your trip before logging out.'), findsOneWidget);
  });
}
