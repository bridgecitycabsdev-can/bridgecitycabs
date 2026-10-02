import 'package:dio/dio.dart';

import '../auth/refresh_lock.dart';
import '../auth/token_store.dart';
import '../config/app_config.dart';
import 'json_map.dart';
import 'refresh_policy.dart';

class ApiClient {
  ApiClient({
    required AppConfig config,
    required this.tokens,
    Dio? dio,
    Dio? refreshDio,
    RefreshLock? refreshLock,
  }) : dio = dio ?? Dio(BaseOptions(baseUrl: config.restBase)),
       _refreshDio = refreshDio ?? Dio(BaseOptions(baseUrl: config.restBase)),
       _refreshLock = refreshLock ?? RefreshLock() {
    this.dio.options.baseUrl = config.restBase;
    _refreshDio.options.baseUrl = config.restBase;
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final access = await tokens.readAccess();
          if (access != null && access.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $access';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final options = error.requestOptions;
          final retried = options.extra['retried'] == true;
          if (!shouldAttemptRefresh(
            statusCode: error.response?.statusCode,
            path: options.path,
            retried: retried,
          )) {
            handler.next(error);
            return;
          }
          final next = await refreshAccessToken();
          if (next == null) {
            await tokens.clear();
            handler.next(error);
            return;
          }
          options.headers['Authorization'] = 'Bearer $next';
          options.extra['retried'] = true;
          try {
            final response = await this.dio.fetch<dynamic>(options);
            handler.resolve(response);
          } on DioException catch (replayError) {
            if (replayError.response?.statusCode == 401) {
              await tokens.clear();
            }
            handler.next(replayError);
          }
        },
      ),
    );
  }

  final TokenStore tokens;
  final Dio dio;
  final Dio _refreshDio;
  final RefreshLock _refreshLock;

  /// Mobile clients send the refresh token in the body. They do not send
  /// `X-Client: web`, which is the cookie mode used by the dispatch console.
  Future<String?> refreshAccessToken() {
    return _refreshLock.run(() async {
      final refresh = await tokens.readRefresh();
      if (refresh == null || refresh.isEmpty) return null;
      try {
        final response = await _refreshDio.post<dynamic>(
          '/auth/refresh',
          data: {'refreshToken': refresh},
        );
        final body = jsonMap(response.data);
        final access = body?['accessToken'];
        final rotated = body?['refreshToken'];
        if (access is! String || rotated is! String) return null;
        await tokens.write(access: access, refresh: rotated);
        return access;
      } on DioException {
        return null;
      }
    });
  }

  Future<void> requestOtp(String phone) {
    return dio.post<dynamic>('/auth/otp/request', data: {'phone': phone});
  }

  Future<void> verifyOtp({required String phone, required String code}) async {
    final response = await dio.post<dynamic>(
      '/auth/otp/verify',
      data: {'phone': phone, 'code': code},
    );
    final body = jsonMap(response.data);
    final access = body?['accessToken'];
    final refresh = body?['refreshToken'];
    if (access is! String || refresh is! String) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Sign-in did not return tokens',
      );
    }
    await tokens.write(access: access, refresh: refresh);
  }

  void close() {
    dio.close();
    _refreshDio.close();
  }
}
