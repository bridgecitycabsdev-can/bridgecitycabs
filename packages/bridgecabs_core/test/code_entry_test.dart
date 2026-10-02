import 'package:bridgecabs_core/ui/code_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('resend waits 60 seconds', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CodeEntry(
          phone: '+14035550100',
          onSubmit: (_) async {},
          onResend: () async {},
        ),
      ),
    );

    expect(find.text('Resend in 60s'), findsOneWidget);
    await tester.pump(const Duration(seconds: 59));
    expect(find.text('Resend in 1s'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Resend code'), findsOneWidget);
  });
}
