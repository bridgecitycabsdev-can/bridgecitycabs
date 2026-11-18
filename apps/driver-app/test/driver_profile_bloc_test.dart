import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/profile/profile.dart';

void main() {
  group('DriverProfileBloc Tests', () {
    late FakeDriverProfileRepository repository;
    late DriverProfileBloc bloc;

    setUp(() {
      repository = FakeDriverProfileRepository(
        latency: const Duration(milliseconds: 10),
      );
      bloc = DriverProfileBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state defaults to activeOnline with Shajil Kunhumon and $41.77', () {
      expect(bloc.state.status, DriverProfileStatus.activeOnline);
      expect(bloc.state.activeTab, DriverProfileTab.info);
      expect(bloc.state.profileData.fullName, 'Shajil Kunhumon');
      expect(bloc.state.profileData.todayEarnings, 41.77);
      expect(bloc.state.isActiveOnline, isTrue);
    });

    test('Tab changed updates activeTab', () {
      bloc.add(const DriverProfileTabChanged(DriverProfileTab.documents));
      expect(bloc.state.activeTab, DriverProfileTab.documents);
    });

    test('Tapping shielded credential opens inspection modal', () {
      bloc.add(const DriverProfileStateForced(DriverProfileStatus.expiringSoonInspection));
      expect(bloc.state.isInspectionModalVisible, isTrue);
      expect(bloc.state.inspectedCredential?.title, 'Vehicle insurance');
    });

    test('Dismissing inspection modal clears inspectedCredential', () {
      bloc.add(const DriverProfileStateForced(DriverProfileStatus.expiringSoonInspection));
      expect(bloc.state.isInspectionModalVisible, isTrue);

      bloc.add(const DriverProfileInspectionDismissed());
      expect(bloc.state.isInspectionModalVisible, isFalse);
      expect(bloc.state.inspectedCredential, isNull);
    });

    test('Upload requested emits uploader feedback', () {
      bloc.add(const DriverProfileUploadRequested('cred_dl_1'));
      expect(
        bloc.state.feedbackMessage,
        contains('Opening document uploader for credential cred_dl_1'),
      );
    });

    test('Offline retry sync calls repository and updates telemetry', () async {
      bloc.add(const DriverProfileStateForced(DriverProfileStatus.offlineSyncAlert));
      bloc.add(const DriverProfileSyncRetryPressed());

      expect(bloc.state.isActionLoading, isTrue);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.isActionLoading, isFalse);
      expect(
        bloc.state.feedbackMessage,
        contains('Profile telemetry synced with Lethbridge Dispatch'),
      );
    });

    test('State forcing via QA matrix configures all 4 design states', () {
      // 1. Expired Locked
      bloc.add(const DriverProfileStateForced(DriverProfileStatus.credentialExpiredLocked));
      expect(bloc.state.status, DriverProfileStatus.credentialExpiredLocked);
      expect(bloc.state.activeTab, DriverProfileTab.documents);
      expect(bloc.state.profileData.fullName, 'Marcus Vance');
      final expiredDoc = bloc.state.profileData.credentials.firstWhere(
        (c) => c.status == DriverCredentialStatus.expired,
      );
      expect(expiredDoc.title, contains("Driver's Licence"));

      // 2. Offline Sync Alert
      bloc.add(const DriverProfileStateForced(DriverProfileStatus.offlineSyncAlert));
      expect(bloc.state.status, DriverProfileStatus.offlineSyncAlert);
      expect(bloc.state.availableTabs.length, 3);
      expect(bloc.state.profileData.rating, isNull);

      // 3. Active Online
      bloc.add(const DriverProfileStateForced(DriverProfileStatus.activeOnline));
      expect(bloc.state.status, DriverProfileStatus.activeOnline);
      expect(bloc.state.profileData.todayEarnings, 41.77);
      expect(bloc.state.profileData.assignedVehicle.unitNumber, 'Unit #42');
    });
  });
}
