import 'package:equatable/equatable.dart';
import '../../data/models/profile_config.dart';
import '../../data/models/user_profile_model.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  updateSuccess,
  loggingOut,
  loggedOut,
  error,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile user;
  final bool isNotificationsEnabled;
  final bool isEditing;
  final String? feedbackMessage;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user = ProfileConfig.defaultProfile,
    this.isNotificationsEnabled = true,
    this.isEditing = false,
    this.feedbackMessage,
    this.errorMessage,
  });

  bool get isLoading => status == ProfileStatus.loading;
  bool get isLoggedOut => status == ProfileStatus.loggedOut;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? user,
    bool? isNotificationsEnabled,
    bool? isEditing,
    String? Function()? feedbackMessage,
    String? Function()? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
      isEditing: isEditing ?? this.isEditing,
      feedbackMessage: feedbackMessage != null
          ? feedbackMessage()
          : this.feedbackMessage,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        isNotificationsEnabled,
        isEditing,
        feedbackMessage,
        errorMessage,
      ];
}
