import 'package:equatable/equatable.dart';

class DriverDeleteChecklistItem extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final bool isPassed;
  final bool hasTestHold;

  const DriverDeleteChecklistItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isPassed,
    this.hasTestHold = false,
  });

  DriverDeleteChecklistItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? isPassed,
    bool? hasTestHold,
  }) {
    return DriverDeleteChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isPassed: isPassed ?? this.isPassed,
      hasTestHold: hasTestHold ?? this.hasTestHold,
    );
  }

  @override
  List<Object?> get props => [id, title, subtitle, isPassed, hasTestHold];
}

class DriverDeleteChecklist extends Equatable {
  final List<DriverDeleteChecklistItem> items;
  final List<String> whatWillBeDeleted;
  final List<String> whatMayBeKept;
  final String anonymizedNotice;
  final String reflectionPeriodText;

  const DriverDeleteChecklist({
    required this.items,
    required this.whatWillBeDeleted,
    required this.whatMayBeKept,
    required this.anonymizedNotice,
    required this.reflectionPeriodText,
  });

  bool get isReadyToProceed => items.every((item) => item.isPassed);

  @override
  List<Object?> get props => [
        items,
        whatWillBeDeleted,
        whatMayBeKept,
        anonymizedNotice,
        reflectionPeriodText,
      ];
}
