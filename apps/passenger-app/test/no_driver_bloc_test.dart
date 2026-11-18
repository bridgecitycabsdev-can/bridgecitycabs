import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/no_driver/no_driver.dart';

void main() {
  group('NoDriverBloc Tests', () {
    late MockNoDriverRepository repository;
    late NoDriverBloc bloc;

    setUp(() {
      repository = MockNoDriverRepository(
        retryDelay: const Duration(milliseconds: 10),
        cancelDelay: const Duration(milliseconds: 10),
      );
      bloc = NoDriverBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state defaults to idle and no drivers nearby', () {
      expect(bloc.state.status, NoDriverStatus.idle);
      expect(bloc.state.isIdle, isTrue);
      expect(bloc.state.title, 'No drivers nearby right now');
      expect(bloc.state.subtitle,
          'All our drivers are busy. You can try again or cancel this ride.');
      expect(bloc.state.actionButtonText, 'Try again');
      expect(bloc.state.booking.trackingId, 'BC-123456');
      expect(bloc.state.booking.pickupAddress, '515 5th Ave S, Downtown');
      expect(bloc.state.booking.dropoffAddress, 'Park Place Mall');
      expect(bloc.state.booking.formattedFare, '\$22.10 CAD');
    });

    test('NoDriverStarted initializes custom booking details', () async {
      const customBooking = NoDriverBookingDetails(
        trackingId: 'BC-777888',
        pickupAddress: 'Lethbridge Airport (YQL)',
        dropoffAddress: 'Sandman Signature Lethbridge',
        vehicleTier: 'Sedan • Medium',
        vehicleSpecs: '4 seats',
        fareAmountCad: 28.50,
      );

      bloc.add(const NoDriverStarted(booking: customBooking));

      await expectLater(
        bloc.stream,
        emits(predicate<NoDriverState>((s) {
          return s.status == NoDriverStatus.idle &&
              s.booking.trackingId == 'BC-777888' &&
              s.booking.pickupAddress == 'Lethbridge Airport (YQL)' &&
              s.booking.formattedFare == '\$28.50 CAD';
        })),
      );
    });

    test('retry search transitions to retrySearching then stillNoDriver when failed', () async {
      bloc.add(const NoDriverStarted());
      await pumpEventQueue();

      bloc.add(const NoDriverRetryTapped());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<NoDriverState>((s) {
            return s.status == NoDriverStatus.retrySearching &&
                s.isRetrySearching &&
                s.isAutoReconnecting &&
                s.actionButtonText == 'Searching...';
          }),
          predicate<NoDriverState>((s) {
            return s.status == NoDriverStatus.stillNoDriver &&
                s.isStillNoDriver &&
                s.retryCount == 1 &&
                s.showBackArrow &&
                !s.isAutoReconnecting &&
                s.actionButtonText == 'Try again';
          }),
        ]),
      );
    });

    test('retry search transitions to navigateToTracking when driver becomes available', () async {
      final successRepo = MockNoDriverRepository(
        simulateSuccessOnRetry: true,
        retryDelay: const Duration(milliseconds: 10),
      );
      final successBloc = NoDriverBloc(repository: successRepo);

      successBloc.add(const NoDriverStarted());
      await pumpEventQueue();

      successBloc.add(const NoDriverRetryTapped());

      await expectLater(
        successBloc.stream,
        emitsInOrder([
          predicate<NoDriverState>((s) => s.isRetrySearching),
          predicate<NoDriverState>((s) => s.navigateToTracking),
        ]),
      );

      successBloc.close();
    });

    test('cancel flow transitions to cancelling, releases booking and navigates to home', () async {
      bloc.add(const NoDriverStarted());
      await pumpEventQueue();

      bloc.add(const NoDriverCancelTapped());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<NoDriverState>((s) {
            return s.status == NoDriverStatus.cancelling &&
                s.isCancelling &&
                s.title == 'Cancelling ride request...' &&
                s.subtitle ==
                    'Releasing your dispatch booking and stopping driver search.' &&
                s.actionButtonText == 'Cancelling ride...';
          }),
          predicate<NoDriverState>((s) {
            return s.status == NoDriverStatus.cancelled &&
                s.isCancelled &&
                s.navigateToHome == true;
          }),
        ]),
      );
    });

    test('tapping book different vehicle triggers navigateToOptions', () async {
      bloc.add(const NoDriverStarted());
      await pumpEventQueue();

      bloc.add(const NoDriverBookDifferentVehicleTapped());
      expect(bloc.state.navigateToOptions, isTrue);
    });

    test('tapping copy tracking ID sets isCopiedToClipboard', () async {
      bloc.add(const NoDriverStarted());
      await pumpEventQueue();

      bloc.add(const NoDriverCopyTrackingIdTapped());
      expect(bloc.state.isCopiedToClipboard, isTrue);
    });
  });
}
