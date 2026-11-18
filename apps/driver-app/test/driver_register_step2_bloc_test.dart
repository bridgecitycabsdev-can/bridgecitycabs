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

  @override
  Future<bool> saveStep2VehicleDetails(DriverRegisterStep2Data data) async =>
      shouldSucceed;
}

void main() {
  group('DriverRegisterStep2Bloc Tests', () {
    test('initial state has default values and cannot proceed', () {
      final bloc = DriverRegisterStep2Bloc(
        repository: TestDriverRegisterRepository(),
      );
      expect(bloc.state.status, DriverRegisterStep2Status.initial);
      expect(bloc.state.data.vehicleClass, isNull);
      expect(bloc.state.data.isFormValid, isFalse);
      expect(bloc.state.canProceed, isFalse);
    });

    test('selecting vehicle class updates state data', () {
      final bloc = DriverRegisterStep2Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterVehicleClassSelected(
          DriverVehicleClass.medium));
      expect(bloc.state.data.vehicleClass, DriverVehicleClass.medium);
    });

    test('updating make and model updates state data', () {
      final bloc = DriverRegisterStep2Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterMakeChanged('Toyota'));
      expect(bloc.state.data.make, 'Toyota');
      expect(bloc.state.data.isMakeValid, isTrue);

      bloc.add(const DriverRegisterModelChanged('Camry Hybrid'));
      expect(bloc.state.data.model, 'Camry Hybrid');
      expect(bloc.state.data.isModelValid, isTrue);
    });

    test('selecting vehicle year >= 2014 is valid without error', () {
      final bloc = DriverRegisterStep2Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterYearSelected(2021));
      expect(bloc.state.data.year, 2021);
      expect(bloc.state.data.isYearValid, isTrue);
      expect(bloc.state.yearError, isNull);
    });

    test('selecting vehicle year < 2014 triggers bylaw year error', () {
      final bloc = DriverRegisterStep2Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterYearSelected(2008));
      expect(bloc.state.data.year, 2008);
      expect(bloc.state.data.isYearValid, isFalse);
      expect(bloc.state.yearError, DriverRegisterConfig.yearTooOldError);
      expect(bloc.state.status, DriverRegisterStep2Status.invalid);
    });

    test('plate number updates and validates properly', () {
      final bloc = DriverRegisterStep2Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterPlateChanged('ABC'));
      expect(bloc.state.data.plateNumber, 'ABC');
      expect(bloc.state.data.isPlateValid, isFalse);

      bloc.add(const DriverRegisterPlateChanged('BCC-9482'));
      expect(bloc.state.data.plateNumber, 'BCC-9482');
      expect(bloc.state.data.isPlateValid, isTrue);
    });

    test('dispatch preference toggles update correctly', () {
      final bloc = DriverRegisterStep2Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterVanOnlyToggled(true));
      expect(bloc.state.data.suitableForVanOnly, isTrue);

      bloc.add(const DriverRegisterFemaleDriverToggled(true));
      expect(bloc.state.data.femaleDriverOnly, isTrue);
    });

    test('year picker modal open and dismiss toggles isYearPickerOpen', () {
      final bloc = DriverRegisterStep2Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterYearPickerOpened());
      expect(bloc.state.isYearPickerOpen, isTrue);
      expect(bloc.state.status, DriverRegisterStep2Status.yearPickerModal);

      bloc.add(const DriverRegisterYearPickerDismissed());
      expect(bloc.state.isYearPickerOpen, isFalse);
    });

    test('switching state directly via QA event sets predefined dataset', () {
      final bloc = DriverRegisterStep2Bloc(
        repository: TestDriverRegisterRepository(),
      );

      // Switch to valid (Camry)
      bloc.add(const DriverRegisterStep2StateSwitched(
          DriverRegisterStep2Status.valid));
      expect(bloc.state.status, DriverRegisterStep2Status.valid);
      expect(bloc.state.data.vehicleClass, DriverVehicleClass.medium);
      expect(bloc.state.data.make, 'Toyota');
      expect(bloc.state.data.model, 'Camry Hybrid');
      expect(bloc.state.data.year, 2021);
      expect(bloc.state.data.plateNumber, 'BCC-9482');
      expect(bloc.state.data.femaleDriverOnly, isTrue);
      expect(bloc.state.canProceed, isTrue);

      // Switch to invalid (Echo 2008)
      bloc.add(const DriverRegisterStep2StateSwitched(
          DriverRegisterStep2Status.invalid));
      expect(bloc.state.status, DriverRegisterStep2Status.invalid);
      expect(bloc.state.data.year, 2008);
      expect(bloc.state.yearError, DriverRegisterConfig.yearTooOldError);
      expect(bloc.state.plateError, DriverRegisterConfig.plateInvalidError);
      expect(bloc.state.generalAlertMessage,
          DriverRegisterConfig.generalValidationAlert);

      // Switch to initial
      bloc.add(const DriverRegisterStep2StateSwitched(
          DriverRegisterStep2Status.initial));
      expect(bloc.state.status, DriverRegisterStep2Status.initial);
      expect(bloc.state.data.vehicleClass, isNull);
    });

    test('submitting valid vehicle details emits success', () async {
      final bloc = DriverRegisterStep2Bloc(
        repository: TestDriverRegisterRepository(shouldSucceed: true),
      );

      bloc.add(const DriverRegisterStep2StateSwitched(
          DriverRegisterStep2Status.valid));
      bloc.add(const DriverRegisterStep2Submitted());

      await Future.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.status, DriverRegisterStep2Status.success);
    });
  });
}
