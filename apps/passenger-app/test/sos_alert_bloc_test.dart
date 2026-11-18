import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/sos_alert/sos_alert.dart';

void main() {
  group('SosAlertBloc Unit Tests', () {
    late MockSosAlertRepository repository;
    late SosAlertBloc bloc;

    setUp(() {
      repository = MockSosAlertRepository();
      bloc = SosAlertBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has readyToSend status and correct telemetry', () async {
      bloc.add(const SosAlertStarted());
      await pumpEventQueue();

      expect(bloc.state.status, SosAlertStatus.readyToSend);
      expect(bloc.state.isReady, isTrue);
      expect(bloc.state.locationStatus, LocationServiceStatus.enabled);
      expect(bloc.state.telemetry.tripId, 'BC-123456');
      expect(bloc.state.telemetry.driverName, 'Michael S.');
      expect(bloc.state.telemetry.currentAddress, 'Scenic Dr & 4 Ave S, Lethbridge');
      expect(bloc.state.beaconPingCount, 0);
      expect(bloc.state.shouldShowLocationWarning, isFalse);
      expect(bloc.state.shouldShowConnectionWarning, isFalse);
    });

    test('SosAlertSendTapped transitions to active on success and increments beacon ping', () async {
      bloc.add(const SosAlertStarted());
      await pumpEventQueue();

      bloc.add(const SosAlertSendTapped());
      await pumpEventQueue();

      expect(bloc.state.status, SosAlertStatus.active);
      expect(bloc.state.isActive, isTrue);
      expect(bloc.state.beaconPingCount, 1);
      expect(bloc.state.alertSentTimestamp, isNotNull);
      expect(bloc.state.userFeedbackMessage, contains('Lethbridge Safety Ops'));
    });

    test('SosAlertSendTapped transitions to failed on network error', () async {
      repository.setSimulateNetworkFailure(true);

      bloc.add(const SosAlertStarted(simulateNetworkFailure: true));
      await pumpEventQueue();

      bloc.add(const SosAlertSendTapped());
      await pumpEventQueue();

      expect(bloc.state.status, SosAlertStatus.failed);
      expect(bloc.state.isFailed, isTrue);
      expect(bloc.state.shouldShowConnectionWarning, isTrue);
      expect(bloc.state.networkErrorMessage, contains('Cellular handshake failed'));
    });

    test('SosAlertRetryTapped clears error and resends alert successfully', () async {
      repository.setSimulateNetworkFailure(true);
      bloc.add(const SosAlertStarted(simulateNetworkFailure: true));
      await pumpEventQueue();

      bloc.add(const SosAlertSendTapped());
      await pumpEventQueue();
      expect(bloc.state.isFailed, isTrue);

      // Now restore network connection
      repository.setSimulateNetworkFailure(false);
      bloc.add(const SosAlertRetryTapped());
      await pumpEventQueue();

      expect(bloc.state.status, SosAlertStatus.active);
      expect(bloc.state.isActive, isTrue);
      expect(bloc.state.shouldShowConnectionWarning, isFalse);
    });

    test('SosAlertUpdateLocationTapped re-synchronizes coordinates and increments ping count', () async {
      bloc.add(const SosAlertStarted());
      await pumpEventQueue();

      bloc.add(const SosAlertSendTapped());
      await pumpEventQueue();
      expect(bloc.state.beaconPingCount, 1);

      bloc.add(const SosAlertUpdateLocationTapped());
      await pumpEventQueue();

      expect(bloc.state.beaconPingCount, 2);
      expect(bloc.state.isUpdatingLocation, isFalse);
      expect(bloc.state.userFeedbackMessage, contains('Coordinates re-synchronized'));
    });

    test('location service disabled shows warning and open settings resolves it', () async {
      bloc.add(const SosAlertStarted(locationEnabled: false));
      await pumpEventQueue();

      expect(bloc.state.locationStatus, LocationServiceStatus.disabled);
      expect(bloc.state.shouldShowLocationWarning, isTrue);

      bloc.add(const SosAlertLocationSettingsOpened());
      await pumpEventQueue();

      expect(bloc.state.locationStatus, LocationServiceStatus.enabled);
      expect(bloc.state.shouldShowLocationWarning, isFalse);
    });

    test('SosAlertSendAnywayTapped bypasses location warning and sends alert', () async {
      bloc.add(const SosAlertStarted(locationEnabled: false));
      await pumpEventQueue();

      expect(bloc.state.shouldShowLocationWarning, isTrue);

      bloc.add(const SosAlertSendAnywayTapped());
      await pumpEventQueue();

      expect(bloc.state.status, SosAlertStatus.active);
      expect(bloc.state.dismissedLocationWarning, isTrue);
      expect(bloc.state.shouldShowLocationWarning, isFalse);
    });

    test('SosAlertCancelTapped marks state as cancelled', () async {
      bloc.add(const SosAlertStarted());
      await pumpEventQueue();

      bloc.add(const SosAlertCancelTapped());
      await pumpEventQueue();

      expect(bloc.state.status, SosAlertStatus.cancelled);
      expect(bloc.state.isCancelled, isTrue);
    });
  });
}
