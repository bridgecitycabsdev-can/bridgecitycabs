import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/onboarding/onboarding.dart';

class MockOnboardingRepository implements OnboardingRepository {
  @override
  Future<bool> hasCompletedOnboarding() async => false;

  @override
  Future<void> markOnboardingCompleted() async {}

  @override
  Future<void> resetOnboarding() async {}
}

void main() {
  testWidgets('renders Screen 1 Choose Your Ride with cards and upfront fare', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingPage(repository: MockOnboardingRepository()),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Screen 1
    expect(find.text('CHOOSE YOUR RIDE'), findsOneWidget);
    expect(find.text('Pick the ride that\nfits you.'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Big'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);
    expect(find.textContaining('Guaranteed Upfront Fare'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Lethbridge, AB'), findsOneWidget);
  });

  testWidgets('renders Screen 2 Ride Anywhere with schedule badge and chips', (tester) async {
    final repository = MockOnboardingRepository();
    final bloc = OnboardingBloc(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<OnboardingBloc>.value(
          value: bloc,
          child: const OnboardingPage(),
        ),
      ),
    );

    bloc.emit(const OnboardingRideAnywhereState());
    await tester.pumpAndSettle();

    // Verify Screen 2
    expect(find.text('RIDE ANYWHERE'), findsOneWidget);
    expect(find.text('Now, later or city to\ncity.'), findsOneWidget);
    expect(find.text('Fixed Rates'), findsOneWidget);
    expect(find.text('24/7 Dispatch'), findsOneWidget);
    expect(find.text('YYC Flights'), findsOneWidget);
    expect(find.text('Schedule Ahead'), findsOneWidget);
    expect(find.text('In transit'), findsOneWidget);
    expect(find.text('CABS • YQL'), findsOneWidget);

    bloc.close();
  });

  testWidgets('renders Screen 3 Safe & Supported with Get Started button', (tester) async {
    final repository = MockOnboardingRepository();
    final bloc = OnboardingBloc(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<OnboardingBloc>.value(
          value: bloc,
          child: const OnboardingPage(),
        ),
      ),
    );

    bloc.emit(const OnboardingSafetySupportedState());
    await tester.pumpAndSettle();

    // Verify Screen 3
    expect(find.text('SAFE AND SUPPORTED'), findsOneWidget);
    expect(find.text("We've got your back,\n24/7."), findsOneWidget);
    expect(find.text('SECURE'), findsOneWidget);
    expect(find.text('SOS Signal'), findsOneWidget);
    expect(find.text('24/7 Dispatch'), findsOneWidget);
    expect(find.text('Share Trip Live'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
    expect(find.text('LETHBRIDGE'), findsOneWidget);

    bloc.close();
  });
}
