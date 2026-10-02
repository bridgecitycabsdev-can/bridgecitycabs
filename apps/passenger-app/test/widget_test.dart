import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/app.dart';

void main() {
  testWidgets('opens on the Canadian phone screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionProvider.overrideWith(_SignedOut.new)],
        child: const PassengerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mobile number'), findsOneWidget);
    expect(find.text('+1 '), findsOneWidget);
  });
}

class _SignedOut extends SessionController {
  @override
  Future<bool> build() async => false;
}
