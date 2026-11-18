import 'package:dio/dio.dart';

class PlacesRemoteDataSource {
  PlacesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<dynamic> autocomplete({
    required String query,
    required String session,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<dynamic>(
      '/places/autocomplete',
      queryParameters: {'q': query, 'session': session},
      cancelToken: cancelToken,
    );
    return response.data;
  }

  Future<dynamic> details({
    required String placeId,
    required String session,
  }) async {
    final response = await _dio.get<dynamic>(
      '/places/$placeId',
      queryParameters: {'session': session},
    );
    return response.data;
  }

  Future<dynamic> reverse({required double lat, required double lng}) async {
    final response = await _dio.get<dynamic>(
      '/places/reverse',
      queryParameters: {'lat': lat, 'lng': lng},
    );
    return response.data;
  }
}
