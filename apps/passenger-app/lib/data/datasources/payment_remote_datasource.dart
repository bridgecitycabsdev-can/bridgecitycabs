import 'package:dio/dio.dart';

class PaymentRemoteDataSource {
  PaymentRemoteDataSource(this._dio);

  final Dio _dio;

  Future<dynamic> list() async {
    final response = await _dio.get<dynamic>('/passenger/payment-methods');
    return response.data;
  }

  Future<dynamic> config() async {
    final response = await _dio.get<dynamic>('/passenger/payment-methods/config');
    return response.data;
  }

  Future<dynamic> createSetupIntent() async {
    final response = await _dio.post<dynamic>(
      '/passenger/payment-methods/setup-intent',
    );
    return response.data;
  }

  Future<void> setDefault(String id) async {
    await _dio.post<dynamic>('/passenger/payment-methods/$id/default');
  }

  Future<void> remove(String id) async {
    await _dio.delete<dynamic>('/passenger/payment-methods/$id');
  }
}
