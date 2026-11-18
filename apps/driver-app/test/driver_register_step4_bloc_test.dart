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

  @override
  Future<DriverDocumentItem> uploadDocument({
    required DriverDocumentType type,
    required String source,
  }) async {
    return DriverDocumentItem(
      type: type,
      status: DocumentUploadStatus.uploaded,
      fileName: 'test.jpg',
    );
  }

  @override
  Future<bool> submitStep3Documents(DriverRegisterStep3Data data) async =>
      shouldSucceed;

  @override
  Future<DriverRegisterStep4Data> checkApplicationStatus() async {
    return const DriverRegisterStep4Data(
      driverName: 'Marcus Vance',
      vehicleModel: 'Toyota Camry Hybrid',
      vehicleYear: 2021,
      fleetId: '#409',
      fleetTag: 'Active Partner',
      milestones: [
        DriverApplicationMilestone(
          title: 'Application submitted',
          subtitle: 'Driver profile received',
          status: MilestoneStatus.completed,
        ),
      ],
    );
  }

  @override
  Future<bool> retryConnection() async => shouldSucceed;
}

void main() {
  group('DriverRegisterStep4Bloc Tests', () {
    test('initial state defaults to reviewing and has milestones populated', () {
      final bloc = DriverRegisterStep4Bloc(
        repository: TestDriverRegisterRepository(),
      );
      expect(bloc.state.status, DriverRegisterStep4Status.reviewing);
      expect(bloc.state.isReviewing, isTrue);
      expect(bloc.state.isApproved, isFalse);
    });

    test('refreshing status updates data from repository', () async {
      final bloc = DriverRegisterStep4Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterStep4RefreshRequested());
      expect(bloc.state.isRefreshing, isTrue);

      await Future.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.isRefreshing, isFalse);
      expect(bloc.state.data.fleetId, '#409');
      expect(bloc.state.feedbackMessage, isNotNull);
    });

    test('reconnecting from offline restores status to reviewing on success',
        () async {
      final bloc = DriverRegisterStep4Bloc(
        repository: TestDriverRegisterRepository(shouldSucceed: true),
      );

      bloc.add(const DriverRegisterStep4StateSwitched(
          DriverRegisterStep4Status.offline));
      expect(bloc.state.isOffline, isTrue);

      bloc.add(const DriverRegisterStep4ReconnectRequested());
      expect(bloc.state.isReconnecting, isTrue);

      await Future.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.isReconnecting, isFalse);
      expect(bloc.state.isReviewing, isTrue);
      expect(bloc.state.feedbackMessage,
          'Connection restored to Lethbridge fleet server!');
    });

    test('go to home and fix documents trigger feedback actions', () {
      final bloc = DriverRegisterStep4Bloc(
        repository: TestDriverRegisterRepository(),
      );

      bloc.add(const DriverRegisterStep4GoHomeRequested());
      expect(bloc.state.feedbackMessage,
          'Redirecting to Driver Home dashboard...');

      bloc.add(const DriverRegisterStep4FixDocumentsRequested());
      expect(bloc.state.feedbackMessage,
          'Navigating to document re-upload...');

      bloc.add(const DriverRegisterStep4UpdateVehicleRequested());
      expect(bloc.state.feedbackMessage, 'Navigating to vehicle update...');

      bloc.add(const DriverRegisterStep4ContactSupportRequested());
      expect(bloc.state.feedbackMessage, contains('403-328-8888'));
    });

    test('switching state directly via QA event reproduces all 5 screen states',
        () {
      final bloc = DriverRegisterStep4Bloc(
        repository: TestDriverRegisterRepository(),
      );

      // 1. Approved (Image 1)
      bloc.add(const DriverRegisterStep4StateSwitched(
          DriverRegisterStep4Status.approved));
      expect(bloc.state.isApproved, isTrue);
      expect(bloc.state.data.fleetTag, 'Active Partner');
      expect(bloc.state.data.milestones.length, 3);
      expect(bloc.state.data.milestones.every((m) => m.status.isCompleted),
          isTrue);

      // 2. Reviewing (Image 2)
      bloc.add(const DriverRegisterStep4StateSwitched(
          DriverRegisterStep4Status.reviewing));
      expect(bloc.state.isReviewing, isTrue);
      expect(bloc.state.data.fleetTag, 'Hybrid Fleet');
      expect(bloc.state.data.milestones[1].status.isInProgress, isTrue);

      // 3. Action Required (Image 3)
      bloc.add(const DriverRegisterStep4StateSwitched(
          DriverRegisterStep4Status.actionRequired));
      expect(bloc.state.isActionRequired, isTrue);
      expect(bloc.state.data.flaggedDocumentName, "Driver's Licence");
      expect(bloc.state.data.milestones[1].status.isActionRequired, isTrue);

      // 4. Rejected (Image 4)
      bloc.add(const DriverRegisterStep4StateSwitched(
          DriverRegisterStep4Status.rejected));
      expect(bloc.state.isRejected, isTrue);
      expect(bloc.state.data.vehicleYear, 2008);
      expect(bloc.state.data.fleetTag, 'INELIGIBLE VEHICLE');
      expect(bloc.state.data.milestones[1].status.isRejected, isTrue);

      // 5. Offline (Image 5)
      bloc.add(const DriverRegisterStep4StateSwitched(
          DriverRegisterStep4Status.offline));
      expect(bloc.state.isOffline, isTrue);
      expect(bloc.state.data.offlinePhone, '403-328-8888');
    });
  });
}
