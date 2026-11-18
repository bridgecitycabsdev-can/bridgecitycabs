import 'package:equatable/equatable.dart';

class DriverDispatchQueueInfo extends Equatable {
  final String broadcastId;
  final String broadcastZone;
  final String winningUnit;
  final int queuePosition;
  final String queueStatus;
  final String responseTime;
  final String areaDemand;
  final int autoReturnSeconds;

  const DriverDispatchQueueInfo({
    this.broadcastId = '#8429',
    this.broadcastZone = 'Lethbridge Central',
    this.winningUnit = 'Unit 18 in Downtown Lethbridge',
    this.queuePosition = 1,
    this.queueStatus = 'STANDBY • POS 1',
    this.responseTime = '1.4s (High Priority)',
    this.areaDemand = 'High Surge (Downtown)',
    this.autoReturnSeconds = 4,
  });

  DriverDispatchQueueInfo copyWith({
    String? broadcastId,
    String? broadcastZone,
    String? winningUnit,
    int? queuePosition,
    String? queueStatus,
    String? responseTime,
    String? areaDemand,
    int? autoReturnSeconds,
  }) {
    return DriverDispatchQueueInfo(
      broadcastId: broadcastId ?? this.broadcastId,
      broadcastZone: broadcastZone ?? this.broadcastZone,
      winningUnit: winningUnit ?? this.winningUnit,
      queuePosition: queuePosition ?? this.queuePosition,
      queueStatus: queueStatus ?? this.queueStatus,
      responseTime: responseTime ?? this.responseTime,
      areaDemand: areaDemand ?? this.areaDemand,
      autoReturnSeconds: autoReturnSeconds ?? this.autoReturnSeconds,
    );
  }

  @override
  List<Object?> get props => [
    broadcastId,
    broadcastZone,
    winningUnit,
    queuePosition,
    queueStatus,
    responseTime,
    areaDemand,
    autoReturnSeconds,
  ];
}
