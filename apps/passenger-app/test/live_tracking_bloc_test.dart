import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/live_tracking/live_tracking.dart';

void main() {
  group('LiveTrackingBloc Tests', () {
    late MockLiveTrackingRepository repository;
    late LiveTrackingBloc bloc;

    setUp(() {
      repository = MockLiveTrackingRepository();
      bloc = LiveTrackingBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
      repository.dispose();
    });

    test('initial state defaults to driverAssigned with Michael', () {
      expect(bloc.state.status, LiveTrackingStatus.driverAssigned);
      expect(bloc.state.isDriverAssigned, isTrue);
      expect(bloc.state.title, 'Michael is assigned to your ride');
      expect(bloc.state.subtitle, 'Heading to pickup point shortly');
      expect(bloc.state.pillText, 'Driver assigned');
      expect(bloc.state.driver.name, 'Michael');
      expect(bloc.state.driver.vehicleModel, 'White Toyota Corolla');
      expect(bloc.state.driver.licensePlate, 'BCC • 892');
      expect(bloc.state.trip.formattedFare, '\$22.10 CAD');
    });

    test('LiveTrackingStarted initializes custom trip details', () async {
      const customTrip = TrackingTripDetails(
        trackingId: 'BC-999111',
        pickupAddress: 'Lethbridge Public Library',
        dropoffAddress: 'Enmax Centre',
        fareAmountCad: 19.50,
      );

      bloc.add(const LiveTrackingStarted(trip: customTrip));

      await expectLater(
        bloc.stream,
        emits(predicate<LiveTrackingState>((s) {
          return s.trip.trackingId == 'BC-999111' &&
              s.trip.pickupAddress == 'Lethbridge Public Library' &&
              s.trip.formattedFare == '\$19.50 CAD';
        })),
      );
    });

    test('status transition to driverArrived updates title and subtitle', () async {
      bloc.add(const LiveTrackingStarted());
      await pumpEventQueue();

      bloc.add(const LiveTrackingStatusChanged(LiveTrackingStatus.driverArrived));

      await expectLater(
        bloc.stream,
        emits(predicate<LiveTrackingState>((s) {
          return s.status == LiveTrackingStatus.driverArrived &&
              s.isDriverArrived &&
              s.title == 'Michael has arrived' &&
              s.subtitle == 'Look for White Toyota Corolla (BCC • 892)' &&
              s.pillText == 'Driver has arrived';
        })),
      );
    });

    test('status transition to driverArriving updates title', () async {
      bloc.add(const LiveTrackingStarted());
      await pumpEventQueue();

      bloc.add(const LiveTrackingStatusChanged(LiveTrackingStatus.driverArriving));

      await expectLater(
        bloc.stream,
        emits(predicate<LiveTrackingState>((s) {
          return s.status == LiveTrackingStatus.driverArriving &&
              s.isDriverArriving &&
              s.title == 'Your driver is arriving in 3 min' &&
              s.pillText == 'Driver arriving • 3 min';
        })),
      );
    });

    test('progress update sets trip progress and ETA', () async {
      bloc.add(const LiveTrackingStarted());
      await pumpEventQueue();

      bloc.add(const LiveTrackingProgressUpdated(
        progress: 0.45,
        etaMinutes: 8,
        estimatedArrivalTime: '3:38 PM',
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<LiveTrackingState>((s) {
          return s.trip.tripProgress == 0.45 &&
              s.trip.etaMinutes == 8 &&
              s.trip.estimatedArrivalTime == '3:38 PM';
        })),
      );
    });

    test('telemetry sync toggling sets isTelemetrySyncing', () async {
      bloc.add(const LiveTrackingStarted());
      await pumpEventQueue();

      bloc.add(const LiveTrackingTelemetrySyncToggled(true));

      await expectLater(
        bloc.stream,
        emits(predicate<LiveTrackingState>((s) {
          return s.isTelemetrySyncing &&
              s.status == LiveTrackingStatus.telemetrySyncing &&
              s.subtitle == '~3 min';
        })),
      );
    });

    test('SOS emergency trigger and cancellation cycle', () async {
      bloc.add(const LiveTrackingStarted());
      await pumpEventQueue();

      // Trigger SOS
      bloc.add(const LiveTrackingSosTriggered());

      await expectLater(
        bloc.stream,
        emits(predicate<LiveTrackingState>((s) {
          return s.isSosTriggered &&
              s.status == LiveTrackingStatus.sosTriggered &&
              s.title == 'SOS Emergency Alert Triggered';
        })),
      );

      // Cancel SOS
      bloc.add(const LiveTrackingSosCancelled());

      await expectLater(
        bloc.stream,
        emits(predicate<LiveTrackingState>((s) {
          return !s.isSosTriggered &&
              s.status == LiveTrackingStatus.tripInProgress;
        })),
      );
    });

    test('cancel ride flow cancels trip and navigates home', () async {
      bloc.add(const LiveTrackingStarted());
      await pumpEventQueue();

      bloc.add(const LiveTrackingCancelRideTapped());
      expect(bloc.state.showCancelDialog, isTrue);

      bloc.add(const LiveTrackingCancelConfirmed());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<LiveTrackingState>((s) => !s.showCancelDialog),
          predicate<LiveTrackingState>((s) {
            return s.status == LiveTrackingStatus.cancelled &&
                s.navigateToHome == true;
          }),
        ]),
      );
    });
  });
}
