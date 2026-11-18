import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/profile/profile.dart';

void main() {
  group('ProfileBloc Unit Tests', () {
    late MockProfileRepository repository;
    late ProfileBloc bloc;

    setUp(() {
      repository = MockProfileRepository();
      bloc = ProfileBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state loads profile from repository', () async {
      bloc.add(const ProfileStarted());
      await pumpEventQueue();

      expect(bloc.state.status, ProfileStatus.loaded);
      expect(bloc.state.user.fullName, 'Robert Vance');
      expect(bloc.state.user.rating, 5.0);
      expect(bloc.state.user.totalRides, 42);
      expect(bloc.state.user.isVerified, isTrue);
      expect(bloc.state.user.email, 'robert.vance@uleth.ca');
      expect(bloc.state.isNotificationsEnabled, isTrue);
    });

    test('ProfileNotificationToggleTapped updates toggle state and repository', () async {
      bloc.add(const ProfileStarted());
      await pumpEventQueue();

      bloc.add(const ProfileNotificationToggleTapped(false));
      await pumpEventQueue();

      expect(bloc.state.isNotificationsEnabled, isFalse);
      expect(bloc.state.user.notificationsEnabled, isFalse);
      expect(bloc.state.feedbackMessage, contains('turned off'));

      bloc.add(const ProfileNotificationToggleTapped(true));
      await pumpEventQueue();

      expect(bloc.state.isNotificationsEnabled, isTrue);
      expect(bloc.state.user.notificationsEnabled, isTrue);
      expect(bloc.state.feedbackMessage, contains('turned on'));
    });

    test('editing profile saves updated full name and email', () async {
      bloc.add(const ProfileStarted());
      await pumpEventQueue();

      bloc.add(const ProfileEditProfileTapped());
      expect(bloc.state.isEditing, isTrue);

      bloc.add(const ProfileSaveEditedProfile(
        fullName: 'Robert Vance Jr.',
        email: 'rvance.jr@uleth.ca',
      ));
      await pumpEventQueue();

      expect(bloc.state.status, ProfileStatus.updateSuccess);
      expect(bloc.state.user.fullName, 'Robert Vance Jr.');
      expect(bloc.state.user.email, 'rvance.jr@uleth.ca');
      expect(bloc.state.isEditing, isFalse);
      expect(bloc.state.feedbackMessage, contains('updated'));
    });

    test('logout event updates state to loggedOut', () async {
      bloc.add(const ProfileStarted());
      await pumpEventQueue();

      bloc.add(const ProfileLogoutTapped());
      await pumpEventQueue();

      expect(bloc.state.status, ProfileStatus.loggedOut);
      expect(bloc.state.isLoggedOut, isTrue);
      expect(bloc.state.feedbackMessage, contains('Logged out'));
    });

    test('navigation and action events emit expected feedback messages', () async {
      bloc.add(const ProfileStarted());
      await pumpEventQueue();

      bloc.add(const ProfileContactSupportTapped());
      expect(bloc.state.feedbackMessage, contains('Support'));

      bloc.add(const ProfileOpenPaymentMethodsTapped());
      expect(bloc.state.feedbackMessage, contains('Payment Methods'));

      bloc.add(const ProfileOpenPrivacyTapped());
      expect(bloc.state.feedbackMessage, contains('Privacy'));

      bloc.add(const ProfileBecomeDriverTapped());
      expect(bloc.state.feedbackMessage, contains('Driver'));

      bloc.add(const ProfileCallRegionalDispatchTapped());
      expect(bloc.state.feedbackMessage, contains('(403) 327-4005'));
    });
  });
}
