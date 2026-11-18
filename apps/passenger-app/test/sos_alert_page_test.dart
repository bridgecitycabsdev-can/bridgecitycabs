import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/sos_alert/sos_alert.dart';

void main() {
  Widget createTestWidget({
    SosRideTelemetry? initialTelemetry,
    SosAlertStatus? initialStatus,
    bool? locationEnabled,
    bool? simulateNetworkFailure,
    SosAlertRepository? repository,
  }) {
    return MaterialApp(
      home: SosAlertPage(
        initialTelemetry: initialTelemetry,
        initialStatus: initialStatus,
        locationEnabled: locationEnabled,
        simulateNetworkFailure: simulateNetworkFailure,
        repository: repository,
      ),
    );
  }

  group('SosAlertPage Widget Tests', () {
    testWidgets('renders confirmation state (Screen 1) with location and transit info', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Emergency Sos'), findsOneWidget);
      expect(find.text('Send emergency alert?'), findsOneWidget);
      expect(find.text('CURRENT LOCATION'), findsOneWidget);
      expect(find.text('Scenic Dr & 4 Ave S, Lethbridge'), findsOneWidget);
      expect(find.text('ASSIGNED TRANSIT'), findsOneWidget);
      expect(find.textContaining('Trip BC-123456 • Michael S.'), findsOneWidget);
      expect(find.textContaining('Toyota Camry • Silver'), findsOneWidget);
      expect(find.text('Send SOS'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('If you are in immediate danger, also call 911.'), findsOneWidget);
    });

    testWidgets('tapping Send SOS transitions to dispatch alert active (Screen 2)', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final sendButton = find.widgetWithText(ElevatedButton, 'Send SOS');
      expect(sendButton, findsOneWidget);

      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      expect(find.text('Dispatch Alert Active'), findsOneWidget);
      expect(find.text('BRIDGE CITY SAFETY ACTIVE'), findsOneWidget);
      expect(find.text('Live Link'), findsOneWidget);
      expect(find.text('Alert sent'), findsOneWidget);
      expect(find.textContaining('Our safety team has been notified'), findsOneWidget);
      expect(find.textContaining('Team notified'), findsOneWidget);
      expect(find.text('Lethbridge 24/7 Safety Desk'), findsOneWidget);
      expect(find.text('GPS Beacon Active'), findsOneWidget);
      expect(find.textContaining('Pinging every 5s'), findsOneWidget);
      expect(find.text('Send location again'), findsOneWidget);
      expect(find.text('Back to trip'), findsOneWidget);
      expect(find.text(SosAlertConfig.clearanceDisclaimer), findsOneWidget);
      expect(find.text('Call 911 immediately'), findsOneWidget);
    });

    testWidgets('renders location and connection warning banners (Screen 3)', (tester) async {
      await tester.pumpWidget(createTestWidget(
        locationEnabled: false,
        simulateNetworkFailure: true,
      ));
      await tester.pumpAndSettle();

      // Location warning
      expect(find.text(SosAlertConfig.locationWarningTitle), findsOneWidget);
      expect(find.text('Open settings'), findsOneWidget);
      expect(find.text('Send anyway'), findsOneWidget);

      // Connection warning
      expect(find.text(SosAlertConfig.connectionFailedTitle), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      // Safety Line Fallback
      expect(find.text('Lethbridge Safety Line'), findsOneWidget);
      expect(find.text(SosAlertConfig.safetyLinePhone), findsOneWidget);
    });

    testWidgets('tapping Send location again triggers coordinate update', (tester) async {
      await tester.pumpWidget(createTestWidget(initialStatus: SosAlertStatus.active));
      await tester.pumpAndSettle();

      expect(find.text('Send location again'), findsOneWidget);

      await tester.tap(find.text('Send location again'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Coordinates re-synchronized'), findsOneWidget);
    });
  });
}
