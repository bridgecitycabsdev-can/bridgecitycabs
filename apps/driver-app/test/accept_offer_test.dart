import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:dio/dio.dart';
import 'package:driver_app/features/offer/offer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows expired copy on 410 and retries the same accept URL', (
    tester,
  ) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
    final paths = <String>[];
    var acceptCalls = 0;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          paths.add('${options.method} ${options.path}');
          if (options.path.contains('/accept')) {
            acceptCalls += 1;
            if (acceptCalls == 1) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 410,
                    data: {'message': 'gone'},
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
              return;
            }
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error: 'offline',
              ),
            );
            return;
          }
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: _snapshot(offered: true),
            ),
          );
        },
      ),
    );

    final api = ApiClient(
      config: const AppConfig(
        restBase: 'http://test/api/v1',
        wsOrigin: 'http://test',
      ),
      tokens: TokenStore(MemorySecureStore()),
      dio: dio,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          sessionProvider.overrideWith(_SignedIn.new),
          driverStateProvider.overrideWith(_Offered.new),
        ],
        child: const MaterialApp(home: OfferPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Accept'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('This ride is no longer available'), findsOneWidget);
    expect(acceptCalls, 1);

    await tester.tap(find.text('Accept'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(acceptCalls, 2);
    expect(
      paths.where((p) => p.contains('/accept')).every(
        (p) => p.contains('22222222-2222-4222-8222-222222222222'),
      ),
      isTrue,
    );
  });
}

class _SignedIn extends SessionController {
  @override
  Future<bool> build() async => true;
}

class _Offered extends DriverStateController {
  @override
  Future<DriverSnapshot> build() async =>
      DriverSnapshot.tryParse(_snapshot(offered: true))!;
}

Map<String, dynamic> _snapshot({required bool offered}) => {
  'v': 3,
  'status': offered ? 'OFFERED' : 'AVAILABLE',
  'shift': {
    'startedAt': '2026-10-03T18:00:00.000Z',
    'vehicle': {'unitNumber': '7'},
  },
  'booking': null,
  'offer': offered
      ? {
          'id': '22222222-2222-4222-8222-222222222222',
          'expiresAt': '2030-01-01T00:00:00.000Z',
          'serverNow': '2026-10-03T18:00:00.000Z',
          'pickup': {'address': 'A', 'lat': 1.0, 'lng': 2.0},
          'dropoff': {'address': 'B', 'lat': 3.0, 'lng': 4.0},
          'distanceToPickupM': 100,
          'tripDistanceM': 1000,
          'quotedFareCents': 1000,
          'paymentMethod': 'CASH',
          'vanOnly': false,
          'ladyDriverOnly': false,
          'passengerFirstName': 'Sam',
          'notes': null,
        }
      : null,
};
