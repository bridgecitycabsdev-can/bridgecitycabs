import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/splash/splash.dart';

void main() {
  group('DriverSplashPage Widget Tests', () {
    testWidgets('renders State 1 (Initial / Loading) elements correctly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverSplashPage(
            initialStatus: DriverSplashStatus.initial,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      // Brand Logo & Text
      expect(find.text(DriverSplashConfig.appTitle), findsOneWidget);
      expect(find.text(DriverSplashConfig.driverBadgeText), findsOneWidget);
      expect(find.text(DriverSplashConfig.driverTagline), findsOneWidget);
      expect(find.text(DriverSplashConfig.locationText), findsOneWidget);

      // Loading Indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders State 2 (Connecting / Retrying Hub) elements correctly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverSplashPage(
            initialStatus: DriverSplashStatus.connecting,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.text(DriverSplashConfig.stillConnectingText), findsOneWidget);
      expect(find.text('RETRYING LETHBRIDGE HUB'), findsOneWidget);
      expect(find.text(DriverSplashConfig.locationText), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders State 3 (Connection Error / Offline modal) elements correctly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverSplashPage(
            initialStatus: DriverSplashStatus.connectionError,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      // Modal content
      expect(find.byType(DriverOfflineModal), findsOneWidget);
      expect(find.text(DriverSplashConfig.connectionErrorMessage), findsOneWidget);
      expect(find.text(DriverSplashConfig.tryAgainButtonText), findsOneWidget);
      expect(find.text(DriverSplashConfig.locationTextUpper), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('renders State 4 (App Update Required modal) elements correctly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverSplashPage(
            initialStatus: DriverSplashStatus.updateRequired,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      // Top bar elements
      expect(find.text('Fleet Dispatch'), findsOneWidget);
      expect(find.text(DriverSplashConfig.currentVersionText), findsOneWidget);

      // Modal content
      expect(find.byType(DriverUpdateModal), findsOneWidget);
      expect(find.text(DriverSplashConfig.updateAvailableTitle), findsOneWidget);
      expect(find.text(DriverSplashConfig.updateAvailableSubtitle), findsOneWidget);
      expect(find.text(DriverSplashConfig.updateNowButtonText), findsOneWidget);
      expect(find.text(DriverSplashConfig.locationTextUpper), findsOneWidget);
      expect(find.byIcon(Icons.system_update_alt_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('tapping QA matrix bar switches states correctly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverSplashPage(
            initialStatus: DriverSplashStatus.initial,
            showQaToolbar: true,
          ),
        ),
      );
      await tester.pump();

      // QA bar should be present
      expect(find.byType(DriverSplashQaMatrixBar), findsOneWidget);

      // Tap 3. Offline Modal chip
      await tester.tap(find.text('3. Offline Modal'));
      await tester.pump();

      expect(find.byType(DriverOfflineModal), findsOneWidget);
      expect(find.text(DriverSplashConfig.connectionErrorMessage), findsOneWidget);

      // Tap 4. Update Modal chip
      await tester.tap(find.text('4. Update Modal'));
      await tester.pump();

      expect(find.byType(DriverUpdateModal), findsOneWidget);
      expect(find.text(DriverSplashConfig.updateAvailableTitle), findsOneWidget);
    });
  });
}
