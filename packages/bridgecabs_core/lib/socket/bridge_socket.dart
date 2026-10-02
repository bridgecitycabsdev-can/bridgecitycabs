import 'package:socket_io_client/socket_io_client.dart' as io;

import 'socket_auth.dart';

typedef DriverStateHandler = void Function(Map<String, dynamic> snapshot);

/// The Dart socket client cannot pass a token callback, so an unauthenticated
/// connect refreshes over REST, writes the new token into `socket.auth`, and
/// connects again.
class BridgeSocket {
  io.Socket? _socket;
  Future<void>? _recovering;

  void connect({
    required String url,
    required String token,
    required Future<String?> Function() refresh,
    DriverStateHandler? onDriverState,
    void Function(Map<String, dynamic> booking)? onBookingUpdated,
  }) {
    disconnect();
    final socket = io.io(
      url,
      io.OptionBuilder().setTransports(['websocket']).setAuth({
        'token': token,
      }).build(),
    );
    socket.on('driver:state', (data) {
      final snapshot = _asMap(data);
      if (snapshot != null) onDriverState?.call(snapshot);
    });
    socket.on('booking:updated', (data) {
      final booking = _asMap(data);
      if (booking != null) onBookingUpdated?.call(booking);
    });
    socket.on('connect_error', (error) {
      if (!isUnauthenticated(error)) return;
      _recover(socket, refresh);
    });
    _socket = socket;
  }

  bool emit(String event, Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket == null || !socket.connected) return false;
    socket.emit(event, payload);
    return true;
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _recovering = null;
  }

  void _recover(io.Socket socket, Future<String?> Function() refresh) {
    if (_recovering != null) return;
    final flight = () async {
      final next = await refresh();
      if (next == null || next.isEmpty) {
        socket.disconnect();
        return;
      }
      socket.auth = {'token': next};
      socket.connect();
    }();
    _recovering = flight.whenComplete(() {
      _recovering = null;
    });
  }

  Map<String, dynamic>? _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }
}
