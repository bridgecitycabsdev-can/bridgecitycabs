import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/otp/otp.dart';

class MockTestOtpPageRepo implements OtpRepository {
  @override
  Future<bool> verifyOtp(String phone, String code) async => true;

  @override
  Future<void> resendOtp(String phone) async {}
}

void main() {
  testWidgets('renders Screen 3 Initial state with masked phone and success toast', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OtpPage(
          phone: '+15873295577',
          repository: null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.textContaining('••77'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('OTP sent successfully'), findsOneWidget);
    expect(find.text('Verify code'), findsOneWidget);
  });

  testWidgets('renders Screen 2 Autofilled state with badge and Verify code button', (tester) async {
    final repository = MockTestOtpPageRepo();
    final bloc = OtpBloc(
      repository: repository,
      initialPhone: '+15873295577',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<OtpBloc>.value(
          value: bloc,
          child: const OtpPage(phone: '+15873295577'),
        ),
      ),
    );

    bloc.emit(const OtpAutofilledState(
      phone: '+15873295577',
      code: '482915',
    ));
    await tester.pumpAndSettle();

    expect(find.text('Code auto-filled from SMS'), findsOneWidget);
    expect(find.text('End-to-end encrypted dispatch network'), findsOneWidget);
    expect(find.text('Verify code'), findsOneWidget);

    bloc.close();
  });

  testWidgets('renders Screen 4 Verifying state with LOCKED badge and spinner', (tester) async {
    final repository = MockTestOtpPageRepo();
    final bloc = OtpBloc(
      repository: repository,
      initialPhone: '+15873295577',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<OtpBloc>.value(
          value: bloc,
          child: const OtpPage(phone: '+15873295577'),
        ),
      ),
    );

    bloc.emit(const OtpVerifyingState(
      phone: '+15873295577',
      code: '482915',
    ));
    await tester.pumpAndSettle();

    expect(find.text('LOCKED'), findsOneWidget);
    expect(find.text('Verifying code...'), findsOneWidget);
    expect(find.text('Securing local transit channel...'), findsOneWidget);
    expect(find.text('Syncing'), findsOneWidget);

    bloc.close();
  });

  testWidgets('renders Screen 1 Error state with attempts remaining banner', (tester) async {
    final repository = MockTestOtpPageRepo();
    final bloc = OtpBloc(
      repository: repository,
      initialPhone: '+15873295577',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<OtpBloc>.value(
          value: bloc,
          child: const OtpPage(phone: '+15873295577'),
        ),
      ),
    );

    bloc.emit(const OtpErrorState(
      phone: '+15873295577',
      code: '730942',
      attemptsRemaining: 2,
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Incorrect code. Please try again.'), findsOneWidget);
    expect(find.textContaining('(2 attempts remaining)'), findsOneWidget);

    bloc.close();
  });

  testWidgets('renders Screen 5 Expired state with timeout card and resend CTA', (tester) async {
    final repository = MockTestOtpPageRepo();
    final bloc = OtpBloc(
      repository: repository,
      initialPhone: '+15873295577',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<OtpBloc>.value(
          value: bloc,
          child: const OtpPage(phone: '+15873295577'),
        ),
      ),
    );

    bloc.emit(const OtpExpiredState(
      phone: '+15873295577',
      code: '482910',
    ));
    await tester.pumpAndSettle();

    expect(find.text('Code Expired (00:00)'), findsOneWidget);
    expect(find.text('Timeout'), findsOneWidget);
    expect(find.text("Haven't got the code yet?"), findsOneWidget);
    expect(find.text('Resend code now'), findsOneWidget);

    bloc.close();
  });
}
