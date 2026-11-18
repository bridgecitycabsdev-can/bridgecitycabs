import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/profile_setup/profile_setup.dart';

class MockTestProfilePageRepo implements ProfileSetupRepository {
  @override
  Future<void> saveProfile(PassengerProfile profile) async {}

  @override
  Future<PassengerProfile?> getProfile() async => null;
}

void main() {
  testWidgets('renders Screen 2 Valid state with readiness card and Continue to Ride Options', (tester) async {
    final repository = MockTestProfilePageRepo();
    final bloc = ProfileSetupBloc(
      repository: repository,
      initialProfile: const PassengerProfile(
        firstName: 'Sarah',
        lastName: 'Mitchell',
        email: 'sarah.mitchell@uleth.ca',
        postalCode: 'T1K 4A8',
        gender: 'Female',
        photoUrl: 'https://example.com/photo.jpg',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProfileSetupBloc>.value(
          value: bloc,
          child: const ProfileSetupPage(),
        ),
      ),
    );

    bloc.emit(ProfileSetupState(
      status: ProfileSetupStatus.valid,
      profile: const PassengerProfile(
        firstName: 'Sarah',
        lastName: 'Mitchell',
        email: 'sarah.mitchell@uleth.ca',
        postalCode: 'T1K 4A8',
        gender: 'Female',
        photoUrl: 'https://example.com/photo.jpg',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Set up your account'), findsOneWidget);
    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(find.text('Photo added • Change'), findsOneWidget);
    expect(find.text('U of Lethbridge verified'), findsOneWidget);
    expect(find.text('West Lethbridge'), findsOneWidget);
    expect(find.text("You're ready for your first booking!"), findsOneWidget);
    expect(find.text('Continue to Ride Options'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);

    bloc.close();
  });

  testWidgets('renders Screen 3 Validation Error state with top banner and 3 errors', (tester) async {
    final repository = MockTestProfilePageRepo();
    final bloc = ProfileSetupBloc(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProfileSetupBloc>.value(
          value: bloc,
          child: const ProfileSetupPage(),
        ),
      ),
    );

    bloc.emit(ProfileSetupState(
      status: ProfileSetupStatus.invalid,
      hasAttemptedSubmit: true,
      profile: const PassengerProfile(
        firstName: 'Sarah',
        lastName: '',
        email: 'sarah.connor@gmail',
        postalCode: '12345',
        gender: 'Female',
      ),
      lastNameError: 'Last name is required',
      emailError: 'Enter a valid email address',
      postalCodeError: 'Enter a valid Canadian postal code (e.g. T1J 1B7)',
    ));
    await tester.pumpAndSettle();

    expect(find.text('Please fix the 3 highlighted errors to continue.'), findsOneWidget);
    expect(find.text('Last name is required'), findsOneWidget);
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Enter a valid Canadian postal code (e.g. T1J 1B7)'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);

    bloc.close();
  });
}
