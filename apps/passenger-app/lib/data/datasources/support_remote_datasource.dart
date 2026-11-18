import 'package:dio/dio.dart';

class SupportRemoteDataSource {
  SupportRemoteDataSource(this._dio);

  final Dio _dio;

  Future<dynamic> mine() async {
    final response = await _dio.get<dynamic>('/support/tickets/mine');
    return response.data;
  }

  Future<dynamic> get(String id) async {
    final response = await _dio.get<dynamic>('/support/tickets/$id');
    return response.data;
  }

  Future<dynamic> create(Map<String, dynamic> body) async {
    final response = await _dio.post<dynamic>('/support/tickets', data: body);
    return response.data;
  }

  Future<dynamic> addMessage(String id, String body) async {
    final response = await _dio.post<dynamic>(
      '/support/tickets/$id/messages',
      data: {'body': body},
    );
    return response.data;
  }
}
