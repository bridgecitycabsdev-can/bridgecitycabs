import 'package:dio/dio.dart';

class BookingRemoteDataSource {
  BookingRemoteDataSource(this._dio);

  final Dio _dio;

  Future<dynamic> quote(List<Map<String, dynamic>> stops) async {
    final response = await _dio.post<dynamic>(
      '/passenger/fares/quotes',
      data: {'stops': stops},
    );
    return response.data;
  }

  Future<dynamic> create({
    required Map<String, dynamic> body,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<dynamic>(
      '/passenger/bookings',
      data: body,
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return response.data;
  }

  Future<void> cancel(String id) async {
    await _dio.post<dynamic>('/passenger/bookings/$id/cancel', data: {});
  }

  Future<dynamic> retry(String id) async {
    final response = await _dio.post<dynamic>('/passenger/bookings/$id/retry');
    return response.data;
  }

  Future<dynamic> history() async {
    final response = await _dio.get<dynamic>('/passenger/bookings/history');
    return response.data;
  }
}
