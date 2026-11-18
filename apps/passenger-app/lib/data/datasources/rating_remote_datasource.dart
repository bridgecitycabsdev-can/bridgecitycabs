import 'package:dio/dio.dart';

class RatingRemoteDataSource {
  RatingRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> rateDriver({
    required String bookingId,
    required int stars,
    String? comment,
  }) async {
    await _dio.post<dynamic>(
      '/passenger/bookings/$bookingId/rate-driver',
      data: {
        'stars': stars,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
  }
}
