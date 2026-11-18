/// Quality and state of the network / dispatch connection.
enum NetworkQuality {
  /// Strong network and dispatch connection.
  normal,

  /// High latency, low cellular signal, or slow handshake.
  lowSignal,

  /// Complete packet loss, device offline, or server unreachable.
  offline,
}

/// Helper model for connection health diagnostics during app startup.
class ConnectionStatus {
  final NetworkQuality quality;
  final bool isFleetDispatchReachable;
  final String? detailMessage;

  const ConnectionStatus({
    required this.quality,
    required this.isFleetDispatchReachable,
    this.detailMessage,
  });

  bool get isNormal => quality == NetworkQuality.normal;
  bool get isLowSignal => quality == NetworkQuality.lowSignal;
  bool get isOffline => quality == NetworkQuality.offline;
}
