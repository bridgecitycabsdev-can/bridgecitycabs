import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final driverLocationProvider =
    NotifierProvider<DriverLocationController, DriverLocationPing?>(
      DriverLocationController.new,
    );

class DriverLocationController extends Notifier<DriverLocationPing?> {
  @override
  DriverLocationPing? build() => null;

  void apply(DriverLocationPing ping) {
    final booking = ref.read(activeBookingProvider).value;
    if (booking == null || booking.id != ping.bookingId) return;
    state = ping;
  }

  void clear() {
    state = null;
  }
}
