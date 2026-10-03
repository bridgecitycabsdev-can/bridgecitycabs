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
      if (booking == null || booking.isTerminal) return null;
      return booking;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  void apply(ActiveBooking booking) {
    if (booking.isTerminal) {
      state = const AsyncData(null);
      return;
    }
    state = AsyncData(booking);
  }

  void clear() {
    state = const AsyncData(null);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}
