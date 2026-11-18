import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:dio/dio.dart';

import '../../features/booking/draft.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepository {
  BookingRepository(this._remote);

  final BookingRemoteDataSource _remote;

  Future<FareQuotes> quote(BookingDraft draft) async {
    final pickup = draft.pickup;
    final dropoff = draft.dropoff;
    if (pickup == null || dropoff == null) {
      throw StateError('Pickup and drop-off are required');
    }
    final data = await _remote.quote([
      pickup.toStopJson(),
      dropoff.toStopJson(),
    ]);
    final quotes = FareQuotes.tryParse(data);
    if (quotes == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/passenger/fares/quotes'),
        message: 'Could not read fare quotes',
      );
    }
    return quotes;
  }

  Future<ActiveBooking> create({
    required Map<String, dynamic> body,
    required String idempotencyKey,
  }) async {
    final booking = ActiveBooking.tryParse(
      await _remote.create(body: body, idempotencyKey: idempotencyKey),
    );
    if (booking == null) {
      throw StateError('Booking created but could not be read');
    }
    return booking;
  }

  Future<void> cancel(String id) => _remote.cancel(id);

  Future<ActiveBooking?> retry(String id) async {
    return ActiveBooking.tryParse(await _remote.retry(id));
  }
}
