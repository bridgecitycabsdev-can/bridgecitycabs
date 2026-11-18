import 'package:driver_app/features/trip/trip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriverTripBloc Tests', () {
    late FakeDriverTripRepository repository;
    late DriverTripBloc bloc;

    setUp(() {
      repository = FakeDriverTripRepository();
      bloc = DriverTripBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state defaults to Heading to Pickup with Alex M. & Unit #42', () {
      expect(bloc.state.status, DriverTripStatus.headingToPickup);
      expect(bloc.state.isHeadingToPickup, isTrue);
      expect(bloc.state.trip.passenger.name, 'Alex M.');
      expect(bloc.state.trip.unitNumber, 42);
      expect(bloc.state.trip.distanceKm, 1.2);
      expect(bloc.state.trip.etaMinutes, 4);
      expect(bloc.state.trip.pickupAddress, '440 University Dr W, Lethbridge');
      expect(bloc.state.trip.isArrivalLocked, isTrue);
    });

    test('DriverTripStarted loads trip from repository', () async {
      bloc.add(const DriverTripStarted());
      await Future.delayed(const Duration(milliseconds: 150));

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.trip.tripId, 'BC-123456');
    });

    test('DriverTripArrivedPressed respects proximity lock when not bypassed', () {
      bloc.add(const DriverTripArrivedPressed(bypassProximity: false));
      expect(
        bloc.state.toastMessage,
        contains('Get closer to the pickup point to continue (120m away)'),
      );
      expect(bloc.state.status, DriverTripStatus.headingToPickup);
    });

    test('DriverTripArrivedPressed with bypass transitions to waitingForPassenger', () async {
      bloc.add(const DriverTripArrivedPressed(bypassProximity: true));
      await Future.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.status, DriverTripStatus.waitingForPassenger);
      expect(bloc.state.isWaitingForPassenger, isTrue);
      expect(bloc.state.toastMessage, contains('Arrived at pickup point'));
      expect(bloc.state.trip.waitTimeElapsedSeconds, 153); // 2:33 default in preset
      expect(bloc.state.trip.formattedWaitTime, '2:33');
      expect(bloc.state.trip.formattedFreeWaitLimit, '5:00');
    });

    test('DriverTripStartTripPressed transitions status to onTrip', () async {
      bloc.add(const DriverTripStartTripPressed());
      await Future.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.status, DriverTripStatus.onTrip);
      expect(bloc.state.isOnTrip, isTrue);
      expect(bloc.state.toastMessage, contains('Trip started'));
    });

    test('Cancellation flow: request, select reason, keep or confirm', () async {
      // 1. Request cancel
      bloc.add(const DriverTripCancelRequested());
      expect(bloc.state.status, DriverTripStatus.cancelTripModal);
      expect(bloc.state.isCancelModal, isTrue);

      // 2. Select different reason
      bloc.add(const DriverTripCancelReasonSelected(
        DriverCancelReason.passengerNotResponding,
      ));
      expect(
        bloc.state.trip.selectedCancelReason,
        DriverCancelReason.passengerNotResponding,
      );

      // 3. Keep trip restores previous status
      bloc.add(const DriverTripKeepTripPressed());
      expect(bloc.state.status, DriverTripStatus.headingToPickup);

      // 4. Request again and confirm cancel
      bloc.add(const DriverTripCancelRequested());
      bloc.add(const DriverTripCancelConfirmed());
      await Future.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.status, DriverTripStatus.canceled);
      expect(bloc.state.isCanceled, isTrue);
      expect(bloc.state.isCanceledAndReturning, isTrue);
      expect(bloc.state.toastMessage, 'Trip canceled');
    });

    test('DriverTripTelemetryTabSelected updates active tab', () {
      bloc.add(const DriverTripTelemetryTabSelected(3));
      expect(bloc.state.trip.telemetryActiveTab, 3);
    });

    test('DriverTripWaitTimerTicked updates elapsed wait timer', () {
      bloc.add(const DriverTripWaitTimerTicked(154));
      expect(bloc.state.trip.waitTimeElapsedSeconds, 154);
      expect(bloc.state.trip.formattedWaitTime, '2:34');
    });

    test('DriverTripStateForced switches between all 4 visual states', () {
      // 1. Waiting for passenger (Screen 2)
      bloc.add(const DriverTripStateForced(DriverTripStatus.waitingForPassenger));
      expect(bloc.state.status, DriverTripStatus.waitingForPassenger);
      expect(bloc.state.trip.formattedWaitTime, '2:33');
      expect(bloc.state.trip.passenger.serviceSummary, 'SUV • Cash');

      // 2. Cancel modal (Screen 3)
      bloc.add(const DriverTripStateForced(DriverTripStatus.cancelTripModal));
      expect(bloc.state.status, DriverTripStatus.cancelTripModal);
      expect(
        bloc.state.trip.selectedCancelReason,
        DriverCancelReason.passengerAsked,
      );

      // 3. Telemetry Alert (Screen 4)
      bloc.add(const DriverTripStateForced(DriverTripStatus.telemetryAlert));
      expect(bloc.state.status, DriverTripStatus.telemetryAlert);
      expect(bloc.state.trip.telemetryWarningTitle, 'Weak GPS Signal');
      expect(
        bloc.state.trip.dispatchBannerText,
        contains('#14 EN ROUTE TO PICKUP • 432 Scenic Dr S'),
      );

      // 4. Heading to pickup (Screen 1)
      bloc.add(const DriverTripStateForced(DriverTripStatus.headingToPickup));
      expect(bloc.state.status, DriverTripStatus.headingToPickup);
      expect(bloc.state.trip.distanceKm, 1.2);

      // 5. In-Progress Navigation (Screenshot 1)
      bloc.add(const DriverTripStateForced(DriverTripStatus.onTrip));
      expect(bloc.state.status, DriverTripStatus.onTrip);
      expect(bloc.state.trip.corridorTitle, contains('Coulee Crossing'));
      expect(bloc.state.trip.distanceRemainingKm, 2.4);

      // 6. End Trip Modal (Screenshot 2)
      bloc.add(const DriverTripStateForced(DriverTripStatus.endTripModal));
      expect(bloc.state.status, DriverTripStatus.endTripModal);
      expect(bloc.state.trip.computedMeterFareCad, 16.85);

      // 7. Emergency SOS Modal (Screenshot 5 State 5)
      bloc.add(const DriverTripStateForced(DriverTripStatus.emergencySosModal));
      expect(bloc.state.status, DriverTripStatus.emergencySosModal);
      expect(bloc.state.trip.isSosActive, isTrue);
    });

    test('In-progress navigation: end trip request, proximity toggling, and confirmation', () {
      bloc.add(const DriverTripStateForced(DriverTripStatus.onTrip));
      expect(bloc.state.isOnTrip, isTrue);

      // Request end trip
      bloc.add(const DriverTripEndTripRequested());
      expect(bloc.state.status, DriverTripStatus.endTripModal);

      // Toggle proximity mode to within50m
      bloc.add(const DriverTripProximityModeToggled('within50m'));
      expect(bloc.state.trip.dropoffProximityMode, 'within50m');
      expect(bloc.state.trip.computedMeterFareCad, 18.40);

      // Toggle back to far
      bloc.add(const DriverTripProximityModeToggled('far'));
      expect(bloc.state.trip.dropoffProximityMode, 'far');
      expect(bloc.state.trip.computedMeterFareCad, 16.85);

      // Confirm end trip
      bloc.add(const DriverTripEndTripConfirmed());
      expect(bloc.state.isTripEndedAndSummarizing, isTrue);
      expect(bloc.state.toastMessage, contains('Finalizing fare via Bylaw 6138 digital meter'));
    });

    test('Emergency SOS modal request, trigger, and cancel flow', () {
      bloc.add(const DriverTripStateForced(DriverTripStatus.onTrip));

      // Request SOS
      bloc.add(const DriverTripEmergencySosRequested());
      expect(bloc.state.status, DriverTripStatus.emergencySosModal);

      // Trigger SOS
      bloc.add(const DriverTripEmergencySosTriggered());
      expect(bloc.state.toastMessage, contains('EMERGENCY ALERT BROADCAST'));

      // Cancel SOS restores previous state
      bloc.add(const DriverTripEmergencySosCancelled());
      expect(bloc.state.status, DriverTripStatus.onTrip);
    });
  });
}
