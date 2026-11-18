import 'dart:async';
import '../../../../data/datasources/profile_remote_datasource.dart';
import '../models/profile_config.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRepository {
  Future<UserProfile> getUserProfile();
  Future<UserProfile> updateUserProfile(UserProfile profile);
  Future<void> toggleNotifications(bool enabled);
  Future<void> logout();

  /// Saves the name and email collected during profile setup.
  Future<void> saveNames({
    required String firstName,
    required String lastName,
    required String email,
  }) async {}
}

class MockProfileRepository implements ProfileRepository {
  UserProfile _user;
  final Duration delay;

  MockProfileRepository({
    UserProfile? initialUser,
    this.delay = const Duration(milliseconds: 40),
  }) : _user = initialUser ?? ProfileConfig.defaultProfile;

  @override
  Future<UserProfile> getUserProfile() async {
    await Future.delayed(delay);
    return _user;
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    await Future.delayed(delay);
    _user = profile;
    return _user;
  }

  @override
  Future<void> toggleNotifications(bool enabled) async {
    await Future.delayed(delay);
    _user = _user.copyWith(notificationsEnabled: enabled);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(delay);
  }

  @override
  Future<void> saveNames({
    required String firstName,
    required String lastName,
    required String email,
  }) async {}
}

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._remote, {this.onLogout});

  final ProfileRemoteDataSource _remote;
  final Future<void> Function()? onLogout;
  bool _notifications = true;

  @override
  Future<UserProfile> getUserProfile() async {
    return _read(await _remote.get());
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    final parts = profile.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final firstName = parts.isEmpty ? profile.fullName : parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    return _read(
      await _remote.update({
        'firstName': firstName,
        'lastName': lastName,
        'email': profile.email.trim(),
      }),
    );
  }

  @override
  Future<void> saveNames({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    await _remote.update({
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': email.trim(),
    });
  }

  @override
  Future<void> toggleNotifications(bool enabled) async {
    _notifications = enabled;
  }

  @override
  Future<void> logout() async {
    await onLogout?.call();
  }

  UserProfile _read(Object? raw) {
    final json = raw is Map ? raw : const <String, dynamic>{};
    final rating = json['rating'];
    final rides = json['totalRides'];
    return UserProfile(
      id: json['id'] is String ? json['id'] as String : '',
      fullName: json['fullName'] is String ? json['fullName'] as String : '',
      phoneNumber: json['phone'] is String ? json['phone'] as String : '',
      email: json['email'] is String ? json['email'] as String : '',
      rating: rating is num ? rating.toDouble() : 0,
      totalRides: rides is num ? rides.round() : 0,
      memberSince:
          json['memberSince'] is String ? json['memberSince'] as String : '',
      defaultPaymentMethod: json['defaultPaymentMethod'] is String
          ? json['defaultPaymentMethod'] as String
          : 'Cash',
      notificationsEnabled: _notifications,
    );
  }
}
