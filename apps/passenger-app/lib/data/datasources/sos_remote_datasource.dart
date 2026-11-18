import 'package:dio/dio.dart';

class SosRemoteDataSource {
  SosRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> trigger({
    String? bookingId,
    required double lat,
    required double lng,
  }) async {
    await _dio.post<dynamic>(
      '/passenger/sos',
      data: {
        'bookingId': ?bookingId,
        'lat': lat,
        'lng': lng,
      },
    );
  }
}
