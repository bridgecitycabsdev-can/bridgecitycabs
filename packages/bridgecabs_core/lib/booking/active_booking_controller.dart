import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session.dart';
import '../models/active_booking.dart';

final activeBookingProvider =
    AsyncNotifierProvider<ActiveBookingController, ActiveBooking?>(
      ActiveBookingController.new,
    );

class ActiveBookingController extends AsyncNotifier<ActiveBooking?> {
  @override
  Future<ActiveBooking?> build() async {
    try {
      final response = await ref
          .read(apiClientProvider)
          .dio
          .get<dynamic>('/passenger/bookings/active');
      final booking = ActiveBooking.tryParse(response.data);
      if (booking == null) return null;
      // Keep receipt trips until the API drops them (CLOSED).
      if (booking.isLive || booking.isReceipt) return booking;
      return null;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  void apply(ActiveBooking booking) {
    if (booking.isLive || booking.isReceipt) {
      state = AsyncData(booking);
      return;
    }
    state = const AsyncData(null);
  }

  void clear() {
    state = const AsyncData(null);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}
