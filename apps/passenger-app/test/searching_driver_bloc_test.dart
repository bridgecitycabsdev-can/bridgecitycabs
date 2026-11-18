import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/searching_driver/searching_driver.dart';

void main() {
  group('SearchingDriverBloc Tests', () {
    late MockSearchingDriverRepository repository;
    late SearchingDriverBloc bloc;

    setUp(() {
      repository = MockSearchingDriverRepository();
      bloc = SearchingDriverBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
      repository.dispose();
    });

    test('initial state defaults to searching with default Lethbridge booking', () {
      expect(bloc.state.status, SearchingDriverStatus.searching);
      expect(bloc.state.isSearching, isTrue);
      expect(bloc.state.isOnline, isTrue);
      expect(bloc.state.booking.trackingId, 'BC-123456');
      expect(bloc.state.booking.pickupAddress, '515 5th Ave S, Downtown');
      expect(bloc.state.booking.dropoffAddress, 'Park Place Mall');
      expect(bloc.state.title, 'Finding your driver...');
    });

    test('SearchingDriverStarted initializes booking and starts search', () async {
      const customBooking = SearchBookingDetails(
        trackingId: 'BC-999888',
        pickupAddress: 'U of Lethbridge, West Campus',
        dropoffAddress: 'Enmax Centre',
        fareAmountCad: 18.50,
      );

      bloc.add(const SearchingDriverStarted(booking: customBooking));

      await expectLater(
        bloc.stream,
        emits(predicate<SearchingDriverState>((s) {
          return s.status == SearchingDriverStatus.searching &&
              s.booking.trackingId == 'BC-999888' &&
              s.booking.pickupAddress == 'U of Lethbridge, West Campus' &&
              s.booking.fareAmountCad == 18.50;
        })),
      );
    });

    test('SearchingDriverStarted with scheduled booking sets scheduled status', () async {
      const scheduledBooking = SearchBookingDetails(
        trackingId: 'BC-123456',
        isScheduled: true,
        scheduledDateTime: 'Fri, 3:30 PM',
        scheduledDayText: 'Confirmed for Friday afternoon',
      );

      bloc.add(const SearchingDriverStarted(booking: scheduledBooking));

      await expectLater(
        bloc.stream,
        emits(predicate<SearchingDriverState>((s) {
          return s.status == SearchingDriverStatus.scheduled &&
              s.isScheduled &&
              s.title == 'Ride scheduled' &&
              s.cancelButtonText == 'Cancel scheduled ride';
        })),
      );
    });

    test('SearchingDriverDriverFoundSimulated emits driverFound and handles countdown', () async {
      bloc.add(const SearchingDriverStarted());
      await pumpEventQueue();

      bloc.add(const SearchingDriverDriverFoundSimulated());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<SearchingDriverState>((s) {
            return s.status == SearchingDriverStatus.driverFound &&
                s.isDriverFound &&
                s.title == 'Driver found!' &&
                s.driver != null &&
                s.connectingSecondsRemaining == 2;
          }),
        ]),
      );
    });

    test('cancel flow: requested shows dialog, confirmed cancels and navigates to home', () async {
      bloc.add(const SearchingDriverStarted());
      await pumpEventQueue();

      // 1. User requests cancel
      bloc.add(const SearchingDriverCancelRequested());
      expect(bloc.state.showCancelDialog, isTrue);

      // 2. User confirms cancel
      bloc.add(const SearchingDriverCancelConfirmed());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<SearchingDriverState>((s) {
            return s.status == SearchingDriverStatus.cancelling &&
                s.isSubmittingCancel == true &&
                s.showCancelDialog == false &&
                s.title == 'Cancelling booking...';
          }),
          predicate<SearchingDriverState>((s) {
            return s.status == SearchingDriverStatus.cancelled &&
                s.isSubmittingCancel == false &&
                s.navigateToHome == true;
          }),
        ]),
      );
    });

    test('connection drops emits reconnecting status and recovers on reconnection', () async {
      bloc.add(const SearchingDriverStarted());
      await pumpEventQueue();

      // Network drops
      bloc.add(const SearchingDriverConnectionChanged(
        isOnline: false,
        signalStrength: 1,
      ));

      expect(bloc.state.status, SearchingDriverStatus.reconnecting);
      expect(bloc.state.isReconnecting, isTrue);
      expect(bloc.state.signalStrength, 1);
      expect(bloc.state.subtitle, 'Syncing connection with Lethbridge ...');

      // Network recovers
      bloc.add(const SearchingDriverConnectionChanged(
        isOnline: true,
        signalStrength: 4,
      ));

      expect(bloc.state.status, SearchingDriverStatus.searching);
      expect(bloc.state.isReconnecting, isFalse);
      expect(bloc.state.subtitle, 'This usually takes a minute.');
    });

    test('copying tracking ID emits isCopiedToClipboard', () async {
      bloc.add(const SearchingDriverStarted());
      await pumpEventQueue();

      bloc.add(const SearchingDriverCopyTrackingIdTapped());
      expect(bloc.state.isCopiedToClipboard, isTrue);
    });
  });
}
