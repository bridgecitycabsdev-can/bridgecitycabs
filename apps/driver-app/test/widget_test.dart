import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:driver_app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens on the Canadian phone screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionProvider.overrideWith(_SignedOut.new)],
        child: const DriverApp(),
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
