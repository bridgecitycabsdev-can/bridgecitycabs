import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/registration/registration.dart';

void main() {
  group('DriverRegisterStep2Page Widget Tests', () {
    testWidgets('renders State 1 (Valid / Complete) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep2Page(
            initialStatus: DriverRegisterStep2Status.valid,
          ),
        ),
      );
      await tester.pump();

      // App bar
      expect(find.text('Your Vehicle'), findsOneWidget);

      // Progress
      expect(find.text('Step 2 of 4 · Vehicle'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);

      // Vehicle Class
      expect(find.text('Verified for Fleet'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);

      // Hero banner
      expect(find.text('FLEET INSPECTION APPROVED'), findsOneWidget);

      // Vehicle Details
      expect(find.text('All fields confirmed'), findsOneWidget);
      expect(find.text('Toyota'), findsOneWidget);
      expect(find.text('Camry Hybrid'), findsOneWidget);
      expect(find.text('2021'), findsOneWidget);
      expect(find.text('Midnight Black'), findsOneWidget);

      // License Plate
      expect(find.text('BCC-9482'), findsOneWidget);
      expect(find.text('Registered with Lethbridge Vehicle Registry'),
          findsOneWidget);

      // Dispatch Preferences
      expect(find.text('Suitable for van-only requests'), findsOneWidget);
      expect(find.text('Lady-driver-only requests'), findsOneWidget);
      expect(find.text('Opt-in active for Lethbridge safety network'),
          findsOneWidget);

      // Regulatory Card & Footer
      expect(
          find.text('Bridge City Cabs Quality Standards'), findsOneWidget);
      expect(
          find.text('⚖ LETHBRIDGE TAXI COMMISSION BYLAW 5834 COMPLIANT'),
          findsOneWidget);

      // Active Button
      expect(find.text('Next: Driver documents ➔'), findsOneWidget);
    });

    testWidgets('renders State 2 (Initial / Empty) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep2Page(
            initialStatus: DriverRegisterStep2Status.initial,
          ),
        ),
      );
      await tester.pump();

      // Required badge
      expect(find.text('Required'), findsOneWidget);

      // Empty place holders
      expect(find.text('ABC-1234'), findsOneWidget);
      expect(find.text('Enter exact registration plate as issued'),
          findsOneWidget);
      expect(find.text('Year ⌄'), findsOneWidget);
      expect(find.text('Colour ⌄'), findsOneWidget);

      // Disabled Button
      expect(find.text('Next: Upload documents ➔'), findsOneWidget);
    });

    testWidgets('renders State 3 (Vehicle Year Picker Modal) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep2Page(
            initialStatus: DriverRegisterStep2Status.yearPickerModal,
          ),
        ),
      );
      await tester.pump();

      // Modal elements
      expect(find.text('Select Vehicle year'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(
          find.text(
              'Vehicles must be model year 2014 or newer to qualify for Bridge City Cabs in Lethbridge.'),
          findsOneWidget);
      expect(find.text('SELECTED'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byKey(const ValueKey('driver_confirm_year_button')),
          findsOneWidget);
    });

    testWidgets('renders State 4 (Validation Errors) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep2Page(
            initialStatus: DriverRegisterStep2Status.invalid,
          ),
        ),
      );
      await tester.pump();

      // Error Progress
      expect(find.text('STEP 2 OF 4 · VEHICLE'), findsOneWidget);
      expect(find.text('50% Completed'), findsOneWidget);

      // Invalid year & plate text
      expect(find.text('2008'), findsOneWidget);
      expect(find.text('Min. 2014 req.'), findsOneWidget);
      expect(
          find.text(
              '⚠️ ${DriverRegisterConfig.yearTooOldError}'),
          findsOneWidget);
      expect(find.text(DriverRegisterConfig.plateInvalidError),
          findsOneWidget);

      // Error alert banner
      expect(
          find.text('! Please correct the highlighted errors above'),
          findsOneWidget);

      // Bylaw card
      expect(find.text('Lethbridge City Bylaw #5834'), findsOneWidget);

      // Disabled Step 3 button
      expect(find.text('Continue to Step 3 ➔'), findsOneWidget);

      // Footer
      expect(
          find.text('Changes are saved locally until fleet review'),
          findsOneWidget);
    });
  });
}
