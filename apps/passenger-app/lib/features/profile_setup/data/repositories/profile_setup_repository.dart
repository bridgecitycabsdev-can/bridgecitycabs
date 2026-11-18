import 'dart:async';
import '../models/passenger_profile.dart';

abstract class ProfileSetupRepository {
  /// Persists the updated passenger profile to the backend API or local store.
  Future<void> saveProfile(PassengerProfile profile);

  /// Retrieves any previously saved or prefilled profile data.
  Future<PassengerProfile?> getProfile();
}

class ProfileSetupRepositoryImpl implements ProfileSetupRepository {
  PassengerProfile? _cachedProfile;
  final Future<void> Function(PassengerProfile profile)? _customSave;

  ProfileSetupRepositoryImpl({
    Future<void> Function(PassengerProfile profile)? customSave,
    PassengerProfile? initialProfile,
  })  : _customSave = customSave,
        _cachedProfile = initialProfile;

  @override
  Future<void> saveProfile(PassengerProfile profile) async {
    if (_customSave != null) {
      await _customSave!(profile);
      _cachedProfile = profile;
      return;
    }
    // Simulation delay
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    _cachedProfile = profile;
  }

  @override
  Future<PassengerProfile?> getProfile() async {
    return _cachedProfile;
  }
}
