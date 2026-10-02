import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// REST origin and socket origin.
///
/// With no defines, an Android emulator uses `http://10.0.2.2:3000` and an
/// iOS simulator uses `http://localhost:3000`. A physical phone should pass
/// the same HTTPS tunnel URL for both:
/// `--dart-define=API_BASE_URL=https://….trycloudflare.com`
/// `--dart-define=WS_URL=https://….trycloudflare.com`
/// (`cloudflared tunnel --url http://localhost:3000`).
/// A LAN `http://` address is for Android debug builds, which allow cleartext.
/// A value that already ends in `/api/v1` is accepted.
class AppConfig {
  const AppConfig({required this.restBase, required this.wsOrigin});

  final String restBase;
  final String wsOrigin;

  factory AppConfig.resolve({
    bool? android,
    String? apiBaseUrl,
    String? wsUrl,
  }) {
    const envApi = String.fromEnvironment('API_BASE_URL');
    const envWs = String.fromEnvironment('WS_URL');
    final api = (apiBaseUrl ?? envApi).trim();
    final ws = (wsUrl ?? envWs).trim();
    final isAndroid = android ?? _runningOnAndroid();
    final fallback = isAndroid
        ? 'http://10.0.2.2:3000'
        : 'http://localhost:3000';
    final origin = api.isEmpty ? fallback : stripApiPrefix(api);
    return AppConfig(
      restBase: '$origin/api/v1',
      wsOrigin: ws.isEmpty ? origin : stripApiPrefix(ws),
    );
  }

  static String stripApiPrefix(String url) {
    var trimmed = url.trim();
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    const suffix = '/api/v1';
    if (trimmed.endsWith(suffix)) {
      return trimmed.substring(0, trimmed.length - suffix.length);
    }
    return trimmed;
  }

  String socketUrl(String namespace) {
    final path = namespace.startsWith('/') ? namespace : '/$namespace';
    return '$wsOrigin$path';
  }
}

bool _runningOnAndroid() {
  if (kIsWeb) return false;
  return Platform.isAndroid;
}
