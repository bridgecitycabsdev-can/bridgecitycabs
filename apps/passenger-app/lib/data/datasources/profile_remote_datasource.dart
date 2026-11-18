import 'package:dio/dio.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._dio);

  final Dio _dio;

  Future<dynamic> get() async {
    final response = await _dio.get<dynamic>('/passenger/profile');
    return response.data;
  }

  Future<dynamic> update(Map<String, dynamic> body) async {
    final response = await _dio.patch<dynamic>('/passenger/profile', data: body);
    return response.data;
  }

  Future<void> requestDeletionCode() async {
    await _dio.post<dynamic>('/passenger/profile/delete/otp');
  }

  Future<void> deleteAccount({
    required String reason,
    String? feedback,
    required String otp,
  }) async {
    await _dio.post<dynamic>(
      '/passenger/profile/delete',
      data: {
        'reason': reason,
        'feedback': ?feedback,
        'otp': otp,
      },
    );
  }
}
