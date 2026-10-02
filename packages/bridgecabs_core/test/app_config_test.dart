import 'package:bridgecabs_core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('android emulator defaults to 10.0.2.2', () {
    final config = AppConfig.resolve(android: true);
    expect(config.restBase, 'http://10.0.2.2:3000/api/v1');
    expect(config.wsOrigin, 'http://10.0.2.2:3000');
    expect(config.socketUrl('/driver'), 'http://10.0.2.2:3000/driver');
  });

  test('iOS simulator defaults to localhost', () {
    final config = AppConfig.resolve(android: false);
    expect(config.restBase, 'http://localhost:3000/api/v1');
    expect(config.wsOrigin, 'http://localhost:3000');
  });

  test('dart-define overrides and keeps a single api prefix', () {
    final config = AppConfig.resolve(
      android: true,
      apiBaseUrl: 'https://api.example.com/api/v1',
      wsUrl: 'https://api.example.com',
    );
    expect(config.restBase, 'https://api.example.com/api/v1');
    expect(config.wsOrigin, 'https://api.example.com');
  });
}
