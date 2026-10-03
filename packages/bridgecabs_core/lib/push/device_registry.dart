import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Registers and soft-revokes FCM tokens with `POST/DELETE /devices`.
class DeviceRegistry {
  DeviceRegistry(this._dio);

  final Dio _dio;
  String? _lastToken;

  String? get lastToken => _lastToken;

  Future<void> register(String token) async {
    if (kIsWeb) return;
    final info = await PackageInfo.fromPlatform();
    final platform = Platform.isIOS ? 'ios' : 'android';
    await _dio.post<dynamic>(
      '/devices',
      data: <String, dynamic>{
        'token': token,
        'platform': platform,
        'appVersion': info.version,
      },
    );
    _lastToken = token;
  }

  Future<void> unregister([String? token]) async {
    final value = token ?? _lastToken;
    if (value == null || value.isEmpty) return;
    try {
      await _dio.delete<dynamic>('/devices/${Uri.encodeComponent(value)}');
    } on DioException {
      // Local logout still proceeds when the API is unreachable.
    }
    if (_lastToken == value) _lastToken = null;
  }
}
