import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/auth/auth.dart';

class MockTestAuthRepository implements AuthRepository {
  @override
  Future<String> requestOtp(String rawPhone) async => '+15873295577';

  @override
  Future<bool> callDispatchSupport() async => true;
}

void main() {
  testWidgets('renders Screen 3 Empty state with Instant SMS card and disabled button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(repository: MockTestAuthRepository()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Login to start a journey with us.'), findsOneWidget);
    expect(find.text('Instant SMS Verification'), findsOneWidget);
    expect(find.text('e.g. 587 329 5577 (Alberta)'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('renders Screen 1 Valid state with Ready for Dispatch pill', (tester) async {
    final repository = MockTestAuthRepository();
    final bloc = AuthBloc(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const LoginPage(),
        ),
      ),
    );

    bloc.emit(const AuthPhoneValid(
      rawPhone: '5873295577',
      formattedPhone: '(587) 329-5577',
    ));
    await tester.pumpAndSettle();

    expect(find.text('Ready for dispatch across Southern Alberta'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    bloc.close();
  });

  testWidgets('renders Screen 5 Invalid state with error prompt and Regional info', (tester) async {
    final repository = MockTestAuthRepository();
    final bloc = AuthBloc(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const LoginPage(),
        ),
      ),
    );

    bloc.emit(const AuthPhoneInvalid(
      rawPhone: '58732',
      formattedPhone: '(587) 32',
    ));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid phone number'), findsOneWidget);
    expect(find.text('Alberta Regional Code'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsWidgets);

    bloc.close();
  });

  testWidgets('renders Screen 4 Submitting state with Sending code spinner and Edit prompt', (tester) async {
    final repository = MockTestAuthRepository();
    final bloc = AuthBloc(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const LoginPage(),
        ),
      ),
    );

    bloc.emit(const AuthSubmitting(
      rawPhone: '5873295577',
      formattedPhone: '(587) 329-5577',
    ));
    await tester.pumpAndSettle();

    expect(find.text('Dispatching 6-digit PIN'), findsOneWidget);
    expect(find.text('Sending code...'), findsOneWidget);
    expect(find.text('Entered wrong number? '), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);

    bloc.close();
  });

  testWidgets('renders Screen 2 Rate Limited state with Too many attempts banner and Help card', (tester) async {
    final repository = MockTestAuthRepository();
    final bloc = AuthBloc(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const LoginPage(),
        ),
      ),
    );

    bloc.emit(const AuthRateLimited(
      rawPhone: '5873295577',
      formattedPhone: '(587) 329-5577',
      cooldown: CooldownTimer(totalSeconds: 300, remainingSeconds: 296),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Too many attempts'), findsOneWidget);
    expect(find.text('04:56'), findsOneWidget);
    expect(find.text('Wait 5 minutes before requesting another code'), findsOneWidget);
    expect(find.text('Cooldown active'), findsOneWidget);
    expect(find.text('Having trouble logging in?'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);

    bloc.close();
  });
}
