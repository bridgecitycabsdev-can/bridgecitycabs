import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/call_driver/call_driver.dart';

void main() {
  Widget buildTestApp({CallPhase initialPhase = CallPhase.preCallPrompt}) {
    return MaterialApp(
      home: CallDriverPage(initialPhase: initialPhase),
    );
  }

  testWidgets('CallDriverPage renders Screen 1 (Masked Number Protection Sheet)', (tester) async {
    await tester.pumpWidget(buildTestApp(initialPhase: CallPhase.preCallPrompt));
    await tester.pumpAndSettle();

    // Verify driver info
    expect(find.text('Michael'), findsWidgets);
    expect(find.textContaining('Lethbridge City Regulated Driver'), findsOneWidget);
    expect(find.textContaining('Silver Toyota Camry SE'), findsOneWidget);
    expect(find.textContaining('Plate BCF-402'), findsOneWidget);

    // Verify masked number card
    expect(find.text('Masked Number Protection'), findsOneWidget);
    expect(find.textContaining('Your phone number and your driver\'s number stay private'), findsOneWidget);
    expect(find.text('Zero Number Sharing'), findsOneWidget);

    // Verify buttons
    expect(find.text('Call Michael'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Calls may be recorded for safety and quality.'), findsOneWidget);
  });

  testWidgets('CallDriverPromptPage toggles to Screen 2 (Driver Arriving Card)', (tester) async {
    await tester.pumpWidget(buildTestApp(initialPhase: CallPhase.preCallPrompt));
    await tester.pumpAndSettle();

    // Tap toggle button
    final toggleBtn = find.text('Show Arriving Card');
    expect(toggleBtn, findsOneWidget);
    await tester.tap(toggleBtn);
    await tester.pumpAndSettle();

    // Verify Driver Arriving Card
    expect(find.textContaining('Driver arriving in 3 mins'), findsOneWidget);
    expect(find.text('Lethbridge City Fleet'), findsOneWidget);
    expect(find.text('Michael R.'), findsOneWidget);
    expect(find.text('Bridge City Verified Driver'), findsOneWidget);

    // Verify stepper
    expect(find.text('Assigned'), findsOneWidget);
    expect(find.text('Arriving'), findsOneWidget);
    expect(find.text('In Transit'), findsOneWidget);
    expect(find.text('Dropoff'), findsOneWidget);

    // Verify pickup spot card
    expect(find.text('PICKUP SPOT'), findsOneWidget);
    expect(find.text('440 University Dr W'), findsOneWidget);
    expect(find.text('Meet at South Entrance (near bus loop)'), findsOneWidget);
    expect(find.text('Cancel ride'), findsOneWidget);
    expect(find.text('Bridge City Trip Guarantee'), findsOneWidget);
  });

  testWidgets('CallDriverPage renders Screen 3 (Active Dialing & Call Controls)', (tester) async {
    await tester.pumpWidget(buildTestApp(initialPhase: CallPhase.connecting));
    await tester.pumpAndSettle();

    // Verify secure voice header
    expect(find.text('Bridge City Cabs Secure Voice'), findsOneWidget);
    expect(find.text('End-to-End Masked Relay'), findsOneWidget);

    // Verify connecting status
    expect(find.text('Connecting you to Michael...'), findsOneWidget);
    expect(find.text('Establishing encrypted cab relay'), findsOneWidget);

    // Verify QA phase chips
    expect(find.text('● 1. Connecting'), findsOneWidget);
    expect(find.text('2. Ringing'), findsOneWidget);
    expect(find.text('3. Connected'), findsOneWidget);

    // Verify call controls
    expect(find.text('Mute'), findsOneWidget);
    expect(find.text('Keypad'), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Cancel Call'), findsOneWidget);
    expect(find.text('Your personal phone number remains private & hidden.'), findsOneWidget);
  });

  testWidgets('CallDriverPage renders Screen 4 (Call Outcome & Fallback Sheet)', (tester) async {
    await tester.pumpWidget(buildTestApp(initialPhase: CallPhase.outcomeFallback));
    await tester.pumpAndSettle();

    // Verify app bar
    expect(find.text('Call Driver Options'), findsOneWidget);

    // Verify QA scenario inspector
    expect(find.text('QA SCENARIO INSPECTOR'), findsOneWidget);
    expect(find.text('Switch Call Outcome'), findsOneWidget);
    expect(find.text("1. Didn't Answer"), findsOneWidget);
    expect(find.text('2. Driver Busy'), findsOneWidget);
    expect(find.text('3. Connection Error'), findsOneWidget);

    // Verify fallback card
    expect(find.text('NO RESPONSE'), findsOneWidget);
    expect(find.text("Michael didn't answer"), findsWidgets);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    // Verify 24/7 dispatch card
    expect(find.text('NEED URGENT ASSISTANCE?'), findsOneWidget);
    expect(find.text('Lethbridge 24/7 Dispatch: 403-329-5577'), findsOneWidget);
    expect(find.textContaining('Bridge City Cabs protects rider and driver privacy'), findsOneWidget);
  });
}
