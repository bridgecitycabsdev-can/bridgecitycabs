import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/profile_setup/profile_setup.dart';

class MockTestProfileRepository implements ProfileSetupRepository {
  PassengerProfile? savedProfile;

  @override
  Future<void> saveProfile(PassengerProfile profile) async {
    savedProfile = profile;
  }

  @override
  Future<PassengerProfile?> getProfile() async => savedProfile;
}

void main() {
  group('ProfileSetupBloc Tests', () {
    late MockTestProfileRepository repository;
    late ProfileSetupBloc bloc;

    setUp(() {
      repository = MockTestProfileRepository();
      bloc = ProfileSetupBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has editing status with empty profile', () {
      expect(bloc.state.status, ProfileSetupStatus.editing);
      expect(bloc.state.profile.firstName, isEmpty);
      expect(bloc.state.canSubmit, isFalse);
    });

    test('prefilled valid profile emits ProfileSetupStatus.valid', () {
      final validBloc = ProfileSetupBloc(
        repository: repository,
        initialProfile: const PassengerProfile(
          firstName: 'Sarah',
          lastName: 'Mitchell',
          email: 'sarah.mitchell@uleth.ca',
          postalCode: 'T1K 4A8',
          gender: 'Female',
        ),
      );

      validBloc.add(const ProfileSetupStarted(
        initialProfile: PassengerProfile(
          firstName: 'Sarah',
          lastName: 'Mitchell',
          email: 'sarah.mitchell@uleth.ca',
          postalCode: 'T1K 4A8',
          gender: 'Female',
        ),
      ));

      expectLater(
        validBloc.stream,
        emits(predicate<ProfileSetupState>((state) {
          return state.status == ProfileSetupStatus.valid &&
              state.profile.verifiedInstitutionTag == 'U of Lethbridge verified' &&
              state.profile.neighborhoodTag == 'West Lethbridge';
        })),
      );

      validBloc.close();
    });

    test('validating Canadian postal code auto-formats with space and resolves neighborhood', () async {
      bloc.add(const ProfilePostalCodeChanged('t1k4a8'));

      await expectLater(
        bloc.stream,
        emits(predicate<ProfileSetupState>((state) {
          return state.profile.postalCode == 'T1K 4A8' &&
              state.profile.neighborhoodTag == 'West Lethbridge';
        })),
      );
    });

    test('submit with invalid inputs flags errors and emits ProfileSetupStatus.invalid', () async {
      bloc.add(const ProfileFirstNameChanged('Sarah'));
      bloc.add(const ProfileEmailChanged('sarah.connor@gmail'));
      bloc.add(const ProfilePostalCodeChanged('12345'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(const ProfileSubmitRequested());

      await expectLater(
        bloc.stream,
        emits(predicate<ProfileSetupState>((state) {
          return state.status == ProfileSetupStatus.invalid &&
              state.lastNameError != null &&
              state.emailError != null &&
              state.postalCodeError != null &&
              state.errorCount == 3;
        })),
      );
    });

    test('submit with valid inputs emits submitting then success', () async {
      bloc.add(const ProfileFirstNameChanged('Sarah'));
      bloc.add(const ProfileLastNameChanged('Mitchell'));
      bloc.add(const ProfileEmailChanged('sarah.mitchell@uleth.ca'));
      bloc.add(const ProfilePostalCodeChanged('T1K 4A8'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(const ProfileSubmitRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ProfileSetupState>((s) => s.status == ProfileSetupStatus.submitting),
          predicate<ProfileSetupState>((s) {
            return s.status == ProfileSetupStatus.success &&
                s.targetRoute == '/home';
          }),
        ]),
      );

      expect(repository.savedProfile?.firstName, 'Sarah');
      expect(repository.savedProfile?.lastName, 'Mitchell');
    });

    test('skip requested emits skipped status and routes to /home', () async {
      bloc.add(const ProfileSkipRequested());

      await expectLater(
        bloc.stream,
        emits(predicate<ProfileSetupState>((state) {
          return state.status == ProfileSetupStatus.skipped &&
              state.targetRoute == '/home';
        })),
      );
    });
  });
}
