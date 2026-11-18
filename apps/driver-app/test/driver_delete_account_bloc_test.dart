import 'package:driver_app/features/delete_account/delete_account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriverDeleteAccountBloc Tests', () {
    late FakeDriverDeleteAccountRepository repository;
    late DriverDeleteAccountBloc bloc;

    setUp(() {
      repository = FakeDriverDeleteAccountRepository();
      bloc = DriverDeleteAccountBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state defaults to checklistReady with 4 checklist items and 5 safeguard blocks', () async {
      expect(bloc.state.status, DriverDeleteStatus.checklistReady);
      expect(bloc.state.selectedBlockType, DriverDeleteSafeguardBlockType.tripActive);
      expect(bloc.state.isTestHoldActive, isFalse);

      bloc.add(const DriverDeleteStarted());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.checklist, isNotNull);
      expect(bloc.state.checklist!.items.length, 4);
      expect(bloc.state.checklist!.isReadyToProceed, isTrue);
      expect(bloc.state.safeguardBlocks.length, 5);
      expect(bloc.state.canProceedWithDeletion, isTrue);
    });

    test('Switching views transitions status between all 5 states', () {
      bloc.add(const DriverDeleteSwitchView(DriverDeleteStatus.safeguardsBlocked));
      expect(bloc.state.status, DriverDeleteStatus.safeguardsBlocked);

      bloc.add(const DriverDeleteSwitchView(DriverDeleteStatus.deletionRequested));
      expect(bloc.state.status, DriverDeleteStatus.deletionRequested);

      bloc.add(const DriverDeleteSwitchView(DriverDeleteStatus.recoveryBanner));
      expect(bloc.state.status, DriverDeleteStatus.recoveryBanner);

      bloc.add(const DriverDeleteSwitchView(DriverDeleteStatus.emergencyModal));
      expect(bloc.state.status, DriverDeleteStatus.emergencyModal);

      bloc.add(const DriverDeleteSwitchView(DriverDeleteStatus.checklistReady));
      expect(bloc.state.status, DriverDeleteStatus.checklistReady);
    });

    test('Toggling Test Hold blocks deletion and switches to safeguards view', () {
      expect(bloc.state.canProceedWithDeletion, isFalse); // checklist not loaded yet

      bloc.add(const DriverDeleteStarted());
      // Wait for checklist load
      Future.delayed(const Duration(milliseconds: 100));

      // Activate Test Hold
      bloc.add(const DriverDeleteToggleTestHold());
      expect(bloc.state.isTestHoldActive, isTrue);
      expect(bloc.state.status, DriverDeleteStatus.safeguardsBlocked);
      expect(bloc.state.canProceedWithDeletion, isFalse);
      expect(bloc.state.toastMessage, contains('Test Hold activated'));

      // Release Test Hold
      bloc.add(const DriverDeleteToggleTestHold());
      expect(bloc.state.isTestHoldActive, isFalse);
      expect(bloc.state.status, DriverDeleteStatus.checklistReady);
      expect(bloc.state.toastMessage, contains('Test Hold released'));
    });

    test('Selecting safeguard block switches active safeguard block', () async {
      bloc.add(const DriverDeleteStarted());
      await Future.delayed(const Duration(milliseconds: 100));

      bloc.add(const DriverDeleteSelectSafeguardBlock(DriverDeleteSafeguardBlockType.unpaidBalance));
      expect(bloc.state.selectedBlockType, DriverDeleteSafeguardBlockType.unpaidBalance);
      expect(bloc.state.activeSafeguardBlock.tag, 'PAYMENT HOLD');

      bloc.add(const DriverDeleteSelectSafeguardBlock(DriverDeleteSafeguardBlockType.bylawLock));
      expect(bloc.state.selectedBlockType, DriverDeleteSafeguardBlockType.bylawLock);
      expect(bloc.state.activeSafeguardBlock.tag, 'MUNICIPAL BYLAW 5834');
    });

    test('Proceed to confirmation succeeds when ready and navigates to deletionRequested', () async {
      bloc.add(const DriverDeleteStarted());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.canProceedWithDeletion, isTrue);

      bloc.add(const DriverDeleteProceedToConfirmation());
      await Future.delayed(const Duration(milliseconds: 150));

      expect(bloc.state.status, DriverDeleteStatus.deletionRequested);
      expect(bloc.state.toastMessage, contains('30-day grace period initiated'));
    });

    test('Proceed to confirmation is blocked when test hold is active', () async {
      bloc.add(const DriverDeleteStarted());
      await Future.delayed(const Duration(milliseconds: 100));

      bloc.add(const DriverDeleteToggleTestHold());
      expect(bloc.state.canProceedWithDeletion, isFalse);

      bloc.add(const DriverDeleteProceedToConfirmation());
      expect(bloc.state.status, DriverDeleteStatus.safeguardsBlocked);
      expect(bloc.state.toastMessage, contains('Protocol Safeguards Active'));
    });

    test('Restoring account during 30-day grace restores profile and checklistReady', () async {
      bloc.add(const DriverDeleteSwitchView(DriverDeleteStatus.recoveryBanner));
      expect(bloc.state.status, DriverDeleteStatus.recoveryBanner);

      bloc.add(const DriverDeleteRestoreAccount());
      await Future.delayed(const Duration(milliseconds: 150));

      expect(bloc.state.status, DriverDeleteStatus.checklistReady);
      expect(bloc.state.toastMessage, contains('Account fully restored!'));
    });

    test('Go to active trip and complete sign-out actions', () {
      bloc.add(const DriverDeleteGoToActiveTrip());
      expect(bloc.state.navigateToTrip, isTrue);

      bloc.add(const DriverDeleteCompleteSignout());
      expect(bloc.state.isSignedOut, isTrue);
      expect(bloc.state.toastMessage, contains('Signed out of Bridge City Cabs'));
    });
  });
}
