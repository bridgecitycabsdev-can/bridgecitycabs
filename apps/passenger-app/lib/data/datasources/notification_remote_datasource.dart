import 'package:dio/dio.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<dynamic> list() async {
    final response = await _dio.get<dynamic>('/notifications');
    return response.data;
  }

  Future<void> markAllRead() async {
    await _dio.post<dynamic>('/notifications/read-all');
  }

  Future<void> markRead(String id) async {
    await _dio.post<dynamic>('/notifications/$id/read');
  }
}
