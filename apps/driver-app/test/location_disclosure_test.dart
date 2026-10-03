import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:dio/dio.dart';
import 'package:driver_app/features/location/location_disclosure_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Agree posts consents before the page pops', (tester) async {
    final posted = <Map<String, dynamic>>[];
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == '/driver/location-notice') {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {
                    'version': '2026-10-03',
                    'text': 'Test disclosure text for location.',
                  },
                ),
              );
              return;
            }
            if (options.path == '/driver/consents') {
              posted.add(Map<String, dynamic>.from(options.data as Map));
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {
                    'type': 'LOCATION_TRACKING',
                    'version': '2026-10-03',
                    'acceptedAt': '2026-10-03T12:00:00.000Z',
                  },
                ),
              );
              return;
            }
            handler.next(options);
          },
        ),
      );

    final client = ApiClient(
      config: const AppConfig(
        restBase: 'http://localhost/api/v1',
        wsOrigin: 'http://localhost',
      ),
      tokens: TokenStore(MemorySecureStore()),
      dio: dio,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(client)],
        child: const MaterialApp(home: LocationDisclosurePage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Test disclosure text'), findsOneWidget);

    await tester.tap(find.text('Agree'));
    await tester.pumpAndSettle();

    expect(posted, [
      {'type': 'LOCATION_TRACKING', 'version': '2026-10-03'},
    ]);
  });
}
