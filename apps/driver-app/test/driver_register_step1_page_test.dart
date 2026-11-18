import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/registration/registration.dart';

void main() {
  group('DriverRegisterStep1Page Widget Tests', () {
    testWidgets('renders State 1 (Initial / Empty) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep1Page(
            initialStatus: DriverRegisterStep1Status.initial,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      // App bar
      expect(find.text(DriverRegisterConfig.screenTitle), findsOneWidget);

      // Step indicator
      expect(find.text(DriverRegisterConfig.stepInfo), findsOneWidget);
      expect(find.text(DriverRegisterConfig.requiredBadge), findsOneWidget);

      // Photo picker
      expect(find.text(DriverRegisterConfig.requiredRedTag), findsOneWidget);

      // Fields
      expect(find.text(DriverRegisterConfig.firstNameLabel), findsOneWidget);
      expect(find.text(DriverRegisterConfig.lastNameLabel), findsOneWidget);
      expect(find.text(DriverRegisterConfig.verifiedViaSms), findsOneWidget);

      // Button
      expect(find.text(DriverRegisterConfig.nextStepButtonText), findsOneWidget);
    });

    testWidgets('renders State 2 (Valid / 25% complete) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep1Page(
            initialStatus: DriverRegisterStep1Status.valid,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      // Percentage badge
      expect(find.text(DriverRegisterConfig.percentageBadge), findsOneWidget);

      // Photo added success
      expect(find.text('${DriverRegisterConfig.photoAddedSuccess} · '), findsOneWidget);
      expect(find.text(DriverRegisterConfig.changePhotoAction), findsOneWidget);

      // Values
      expect(find.text('Marcus'), findsOneWidget);
      expect(find.text('Vance'), findsOneWidget);
      expect(find.text('marcus.vance@gmail.com'), findsOneWidget);
      expect(find.text(DriverRegisterConfig.verifiedBadge), findsOneWidget);
      expect(find.text('948201-442'), findsOneWidget);
      expect(find.text(DriverRegisterConfig.licenceClassTag), findsOneWidget);
      expect(find.text('T1K 4V7'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);

      // Regulatory card & button
      expect(find.text(DriverRegisterConfig.privacyProtectedTitle), findsOneWidget);
      expect(find.text(DriverRegisterConfig.nextVehicleDetailsButtonText), findsOneWidget);
    });

    testWidgets('renders State 3 (Validation Errors) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep1Page(
            initialStatus: DriverRegisterStep1Status.invalid,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.text(DriverRegisterConfig.photoRequiredError), findsOneWidget);
      expect(find.text(DriverRegisterConfig.invalidSyntaxError), findsOneWidget);
      expect(find.text(DriverRegisterConfig.invalidEmailError), findsOneWidget);
      expect(find.text(DriverRegisterConfig.licenceRequiredError), findsOneWidget);
      expect(find.text(DriverRegisterConfig.postalCodeInvalidError), findsOneWidget);
      expect(find.text(DriverRegisterConfig.generalValidationAlert), findsOneWidget);
      expect(find.text(DriverRegisterConfig.continueToVehicleInfoButtonText), findsOneWidget);
    });

    testWidgets('renders State 4 (Photo Modal) bottom sheet elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep1Page(
            initialStatus: DriverRegisterStep1Status.photoModal,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DriverRegisterPhotoModal), findsOneWidget);
      expect(find.text(DriverRegisterConfig.modalTitle), findsOneWidget);
      expect(find.text(DriverRegisterConfig.modalSubtitle), findsOneWidget);
      expect(find.text(DriverRegisterConfig.badgeIdTitle), findsOneWidget);
      expect(find.text(DriverRegisterConfig.guidelineLighting), findsOneWidget);
      expect(find.text(DriverRegisterConfig.guidelineSunglasses), findsOneWidget);
      expect(find.text(DriverRegisterConfig.guidelineFaceForward), findsOneWidget);
      expect(find.text(DriverRegisterConfig.takePhotoAction), findsOneWidget);
      expect(find.text(DriverRegisterConfig.chooseGalleryAction), findsOneWidget);
      expect(find.text(DriverRegisterConfig.cancelAction), findsOneWidget);
      expect(find.text(DriverRegisterConfig.policeBylawNotice), findsOneWidget);
    });

    testWidgets('tapping QA matrix bar switches between all registration states',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverRegisterStep1Page(
            initialStatus: DriverRegisterStep1Status.initial,
            showQaToolbar: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DriverRegisterQaMatrixBar), findsOneWidget);

      // Switch to Valid (25%)
      await tester.tap(find.text('2. Valid (25%)'));
      await tester.pumpAndSettle();
      expect(find.text(DriverRegisterConfig.percentageBadge), findsOneWidget);
      expect(find.text('Marcus'), findsOneWidget);

      // Switch to Photo Modal
      await tester.tap(find.text('4. Photo Modal'));
      await tester.pumpAndSettle();
      expect(find.byType(DriverRegisterPhotoModal), findsOneWidget);
      expect(find.text(DriverRegisterConfig.modalTitle), findsOneWidget);
    });
  });
}
