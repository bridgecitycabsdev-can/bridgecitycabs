import 'package:equatable/equatable.dart';

enum MilestoneStatus {
  completed,
  inProgress,
  actionRequired,
  rejected,
  pending,
  locked;

  bool get isCompleted => this == MilestoneStatus.completed;
  bool get isInProgress => this == MilestoneStatus.inProgress;
  bool get isActionRequired => this == MilestoneStatus.actionRequired;
  bool get isRejected => this == MilestoneStatus.rejected;
  bool get isPending => this == MilestoneStatus.pending;
  bool get isLocked => this == MilestoneStatus.locked;
}

class DriverApplicationMilestone extends Equatable {
  final String title;
  final String subtitle;
  final String? timestamp;
  final MilestoneStatus status;
  final String? badgeText;
  final List<String> tags;

  const DriverApplicationMilestone({
    required this.title,
    required this.subtitle,
    this.timestamp,
    this.status = MilestoneStatus.pending,
    this.badgeText,
    this.tags = const [],
  });

  DriverApplicationMilestone copyWith({
    String? title,
    String? subtitle,
    String? timestamp,
    MilestoneStatus? status,
    String? badgeText,
    List<String>? tags,
  }) {
    return DriverApplicationMilestone(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      badgeText: badgeText ?? this.badgeText,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        title,
        subtitle,
        timestamp,
        status,
        badgeText,
        tags,
      ];
}
