import 'dart:convert';
import 'dart:typed_data';

import 'package:bridgecabs_core/auth/secure_store.dart';
import 'package:bridgecabs_core/auth/token_store.dart';
import 'package:bridgecabs_core/config/app_config.dart';
import 'package:bridgecabs_core/http/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('two 401s share one refresh and then replay', () async {
    final tokens = TokenStore(MemorySecureStore());
    await tokens.write(access: 'old', refresh: 'refresh-1');
    final adapter = _Script();
    final dio = Dio()..httpClientAdapter = adapter;
    final refreshDio = Dio()..httpClientAdapter = adapter;
    final client = ApiClient(
      config: AppConfig.resolve(android: false),
      tokens: tokens,
      dio: dio,
      refreshDio: refreshDio,
    );

    final results = await Future.wait([
      client.dio.get<Map<String, dynamic>>('/driver/me/state'),
      client.dio.get<Map<String, dynamic>>('/driver/me/state'),
    ]);

    expect(results.map((response) => response.data?['ok']), [true, true]);
    expect(adapter.refreshCalls, 1);
    expect(await tokens.readAccess(), 'new-access');
    expect(await tokens.readRefresh(), 'new-refresh');
    client.close();
  });
}

class _Script implements HttpClientAdapter {
  int refreshCalls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains('/auth/refresh')) {
      refreshCalls += 1;
      return _json(200, {
        'accessToken': 'new-access',
        'refreshToken': 'new-refresh',
      });
    }
    if (options.extra['retried'] == true) {
      return _json(200, {'ok': true});
    }
    return _json(401, {'message': 'unauthorized'});
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Map<String, Object?> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
