import 'package:driver_app/features/flag_ride/flag_ride.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriverFlagRideBloc Tests', () {
    late FakeDriverFlagRideRepository repository;
    late DriverFlagRideBloc bloc;

    setUp(() {
      repository = FakeDriverFlagRideRepository();
      bloc = DriverFlagRideBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state defaults to Start Flag Ride with 2 passengers and \$15.00 CAD fare', () {
      expect(bloc.state.status, DriverFlagRideStatus.startFlagRide);
      expect(bloc.state.ride.passengerCount, 2);
      expect(bloc.state.ride.estimatedFare, 15.00);
      expect(bloc.state.ride.unitNumber, 'Car #104 Assigned');
      expect(bloc.state.ride.pickupAddress, '524 4th Ave S, Downtown Lethbridge');
      expect(bloc.state.ride.gpsSignal, 'HIGH');
      expect(bloc.state.ride.zone, 'Downtown Zone 1');
    });

    test('Passenger count increments and decrements within [1, 4] bounds', () {
      // Initially 2
      expect(bloc.state.ride.passengerCount, 2);

      // Increment to 3
      bloc.add(const DriverFlagIncrementPassengerEvent());
      expect(bloc.state.ride.passengerCount, 3);

      // Increment to 4
      bloc.add(const DriverFlagIncrementPassengerEvent());
      expect(bloc.state.ride.passengerCount, 4);

      // Attempt increment above 4 (should clamp)
      bloc.add(const DriverFlagIncrementPassengerEvent());
      expect(bloc.state.ride.passengerCount, 4);

      // Decrement back down
      bloc.add(const DriverFlagDecrementPassengerEvent());
      expect(bloc.state.ride.passengerCount, 3);
      bloc.add(const DriverFlagDecrementPassengerEvent());
      expect(bloc.state.ride.passengerCount, 2);
      bloc.add(const DriverFlagDecrementPassengerEvent());
      expect(bloc.state.ride.passengerCount, 1);

      // Attempt decrement below 1 (should clamp)
      bloc.add(const DriverFlagDecrementPassengerEvent());
      expect(bloc.state.ride.passengerCount, 1);
    });

    test('Setting destination updates dropOffAddress and recalculates estimated fare', () {
      bloc.add(const DriverFlagSetDestinationEvent('440 University Dr W, West Lethbridge, AB T1K 3M4'));
      expect(
        bloc.state.ride.dropOffAddress,
        '440 University Dr W, West Lethbridge, AB T1K 3M4',
      );
      expect(bloc.state.ride.estimatedFare, 18.50);
    });

    test('Starting flag ride sets inProgress status, runs meter, and navigates', () async {
      bloc.add(const DriverFlagStartRideEvent());
      await Future.delayed(const Duration(milliseconds: 150));

      expect(bloc.state.status, DriverFlagRideStatus.flagInProgress);
      expect(bloc.state.ride.isMeterRunning, isTrue);
      expect(bloc.state.ride.speedKmh, 48);
      expect(bloc.state.ride.computedFare, 12.40);
      expect(bloc.state.ride.elapsedTime, '06:35');
      expect(bloc.state.ride.distanceCoveredKm, 2.4);
      expect(bloc.state.ride.tripProgress, 0.57);
    });

    test('Ending trip moves status to flagComplete and computes cash due with GST', () async {
      // First start the ride
      bloc.add(const DriverFlagStartRideEvent());
      await Future.delayed(const Duration(milliseconds: 150));

      // Now end trip
      bloc.add(const DriverFlagEndTripEvent());
      await Future.delayed(const Duration(milliseconds: 150));

      expect(bloc.state.status, DriverFlagRideStatus.flagComplete);
      expect(bloc.state.ride.isMeterRunning, isFalse);
      expect(bloc.state.ride.totalCashToCollect, 18.60);
      expect(bloc.state.ride.subtotalMeterFare, 17.71);
      expect(bloc.state.ride.gstAlberta, 0.89);
      expect(bloc.state.ride.netDriverEarning, 15.81);
      expect(bloc.state.ride.quickChanges.length, 2);
      expect(bloc.state.ride.quickChanges[0].tenderedAmount, 20.00);
      expect(bloc.state.ride.quickChanges[0].changeDue, 1.40);
      expect(bloc.state.ride.quickChanges[1].tenderedAmount, 25.00);
      expect(bloc.state.ride.quickChanges[1].changeDue, 6.40);
    });

    test('Cash collected event records payment and emits notification toast', () async {
      bloc.add(const DriverFlagForceStateEvent(DriverFlagRideStatus.flagComplete));
      expect(bloc.state.status, DriverFlagRideStatus.flagComplete);

      bloc.add(const DriverFlagCashCollectedEvent());
      await Future.delayed(const Duration(milliseconds: 150));

      expect(bloc.state.ride.isCashCollected, isTrue);
      expect(bloc.state.toastMessage, contains('Cash collected: \$18.60 CAD'));

      bloc.add(const DriverFlagClearToastEvent());
      expect(bloc.state.toastMessage, isNull);
    });

    test('Edge category switching and resolution event handling', () {
      bloc.add(const DriverFlagForceStateEvent(DriverFlagRideStatus.edgeStates));
      expect(bloc.state.status, DriverFlagRideStatus.edgeStates);

      // Select activeRoute category
      bloc.add(const DriverFlagSelectEdgeCategoryEvent(DriverFlagEdgeCategory.activeRoute));
      expect(bloc.state.selectedEdgeCategory, DriverFlagEdgeCategory.activeRoute);
      expect(bloc.state.selectedEdgeState, DriverFlagEdgeState.routeConflict);

      // Select offlineLock category
      bloc.add(const DriverFlagSelectEdgeCategoryEvent(DriverFlagEdgeCategory.offlineLock));
      expect(bloc.state.selectedEdgeCategory, DriverFlagEdgeCategory.offlineLock);
      expect(bloc.state.selectedEdgeState, DriverFlagEdgeState.localBlackoutMode);

      // Select specific edge state
      bloc.add(const DriverFlagSelectEdgeStateEvent(DriverFlagEdgeState.telemetryTimeout));
      expect(bloc.state.selectedEdgeState, DriverFlagEdgeState.telemetryTimeout);

      // Retry telemetry
      bloc.add(const DriverFlagRetryTelemetryEvent());
      expect(bloc.state.toastMessage, contains('Re-attempting telemetry connection...'));

      // Trigger resolution
      bloc.add(const DriverFlagTriggerEdgeResolutionEvent('open_settings'));
      expect(bloc.state.toastMessage, contains('Action executed: open_settings'));
    });

    test('QA Bar force state switches directly between all 4 screen views', () {
      bloc.add(const DriverFlagForceStateEvent(DriverFlagRideStatus.flagInProgress));
      expect(bloc.state.status, DriverFlagRideStatus.flagInProgress);

      bloc.add(const DriverFlagForceStateEvent(DriverFlagRideStatus.flagComplete));
      expect(bloc.state.status, DriverFlagRideStatus.flagComplete);

      bloc.add(const DriverFlagForceStateEvent(DriverFlagRideStatus.edgeStates));
      expect(bloc.state.status, DriverFlagRideStatus.edgeStates);

      bloc.add(const DriverFlagForceStateEvent(DriverFlagRideStatus.startFlagRide));
      expect(bloc.state.status, DriverFlagRideStatus.startFlagRide);
    });
  });
}
