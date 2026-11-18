import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/registration/registration.dart';

class TestDriverRegisterRepository implements DriverRegisterRepository {
  final bool shouldSucceed;

  TestDriverRegisterRepository({this.shouldSucceed = true});

  @override
  Future<bool> saveStep1Details(DriverRegisterStep1Data data) async =>
      shouldSucceed;

  @override
  Future<String?> pickProfilePhoto({required String source}) async =>
      'https://example.com/driver.png';
}

void main() {
  group('DriverRegisterStep1Bloc Tests', () {
    test('initial state has empty data, initial status, and cannot proceed', () {
      final bloc = DriverRegisterStep1Bloc(
        repository: TestDriverRegisterRepository(),
      );
      expect(bloc.state.status, DriverRegisterStep1Status.initial);
      expect(bloc.state.data.hasPhoto, isFalse);
      expect(bloc.state.data.isFormValid, isFalse);
      expect(bloc.state.canProceed, isFalse);
    });

    test('updating fields updates state data correctly', () {
      final bloc = DriverRegisterStep1Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterFirstNameChanged('Marcus'));
      expect(bloc.state.data.firstName, 'Marcus');

      bloc.add(const DriverRegisterLastNameChanged('Vance'));
      expect(bloc.state.data.lastName, 'Vance');

      bloc.add(const DriverRegisterEmailChanged('marcus.vance@gmail.com'));
      expect(bloc.state.data.email, 'marcus.vance@gmail.com');
      expect(bloc.state.data.isEmailValid, isTrue);

      bloc.add(const DriverRegisterLicenceChanged('948201-442'));
      expect(bloc.state.data.driverLicenceNumber, '948201-442');
      expect(bloc.state.data.isLicenceValid, isTrue);

      bloc.add(const DriverRegisterPostalCodeChanged('T1K 4V7'));
      expect(bloc.state.data.postalCode, 'T1K 4V7');
      expect(bloc.state.data.isPostalCodeValid, isTrue);

      bloc.add(const DriverRegisterGenderSelected(DriverGender.male));
      expect(bloc.state.data.gender, DriverGender.male);
    });

    test('photo modal open and dismiss toggles isPhotoModalOpen', () {
      final bloc = DriverRegisterStep1Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterPhotoModalOpened());
      expect(bloc.state.isPhotoModalOpen, isTrue);
      expect(bloc.state.status, DriverRegisterStep1Status.photoModal);

      bloc.add(const DriverRegisterPhotoModalDismissed());
      expect(bloc.state.isPhotoModalOpen, isFalse);
    });

    test('picking photo updates hasPhoto and clears photoError', () async {
      final bloc = DriverRegisterStep1Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterPhotoPicked('camera'));
      await expectLater(
        bloc.stream,
        emits(predicate<DriverRegisterStep1State>(
          (s) =>
              s.data.hasPhoto == true &&
              s.isPhotoModalOpen == false &&
              s.photoError == null,
        )),
      );
    });

    test('submitting with missing fields triggers invalid status with inline errors', () async {
      final bloc = DriverRegisterStep1Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterSubmitted());
      await expectLater(
        bloc.stream,
        emits(predicate<DriverRegisterStep1State>(
          (s) =>
              s.status == DriverRegisterStep1Status.invalid &&
              s.photoError != null &&
              s.emailError != null &&
              s.licenceError != null &&
              s.postalCodeError != null &&
              s.generalAlertMessage != null,
        )),
      );
    });

    test('submitting with all valid fields triggers submitting then success', () async {
      final bloc = DriverRegisterStep1Bloc(
        repository: TestDriverRegisterRepository(shouldSucceed: true),
      );

      bloc.add(const DriverRegisterStateSwitched(DriverRegisterStep1Status.valid));
      expect(bloc.state.status, DriverRegisterStep1Status.valid);
      expect(bloc.state.canProceed, isTrue);

      bloc.add(const DriverRegisterSubmitted());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<DriverRegisterStep1State>(
              (s) => s.status == DriverRegisterStep1Status.submitting),
          predicate<DriverRegisterStep1State>(
              (s) => s.status == DriverRegisterStep1Status.success),
        ]),
      );
    });

    test('state switched handles all 4 states accurately', () {
      final bloc = DriverRegisterStep1Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterStateSwitched(DriverRegisterStep1Status.initial));
      expect(bloc.state.status, DriverRegisterStep1Status.initial);
      expect(bloc.state.data.firstName, '');

      bloc.add(const DriverRegisterStateSwitched(DriverRegisterStep1Status.valid));
      expect(bloc.state.status, DriverRegisterStep1Status.valid);
      expect(bloc.state.data.firstName, 'Marcus');
      expect(bloc.state.data.hasPhoto, isTrue);

      bloc.add(const DriverRegisterStateSwitched(DriverRegisterStep1Status.invalid));
      expect(bloc.state.status, DriverRegisterStep1Status.invalid);
      expect(bloc.state.photoError, isNotNull);
      expect(bloc.state.emailError, isNotNull);

      bloc.add(const DriverRegisterStateSwitched(DriverRegisterStep1Status.photoModal));
      expect(bloc.state.status, DriverRegisterStep1Status.photoModal);
      expect(bloc.state.isPhotoModalOpen, isTrue);
    });
  });
}
