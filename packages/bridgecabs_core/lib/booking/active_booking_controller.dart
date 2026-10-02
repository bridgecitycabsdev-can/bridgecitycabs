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
      return ActiveBooking.tryParse(response.data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  void apply(ActiveBooking booking) {
    state = AsyncData(booking);
  }
}
