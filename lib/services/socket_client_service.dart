import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';

class SocketClientService {
  IO.Socket? _socket;

  // Singleton pattern
  SocketClientService._internal();
  static final SocketClientService instance = SocketClientService._internal();

  IO.Socket? get socket => _socket;

  /// Initialize WebSocket connection
  void connect(String userId) {
    if (_socket != null && _socket!.connected) return;

    debugPrint('Connecting to WebSocket server at ${ApiConfig.wsUrl}...');
    
    _socket = IO.io(ApiConfig.wsUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .enableAutoConnect()
      .build());

    _socket!.onConnect((_) {
      debugPrint('WebSocket connected!');
      // Join user room to receive notifications/alerts
      joinUser(userId);
    });

    _socket!.onDisconnect((_) {
      debugPrint('WebSocket disconnected!');
    });

    _socket!.onConnectError((err) {
      debugPrint('WebSocket connection error: $err');
    });
  }

  /// Disconnect socket connection
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      debugPrint('WebSocket disconnected manually.');
    }
  }

  /// Join user room
  void joinUser(String userId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join_user', userId);
      debugPrint('Joined WebSocket room user_$userId');
    }
  }

  /// Join a journey room for live progress streaming
  void joinJourney(String journeyId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join_journey', journeyId);
      debugPrint('Joined WebSocket room journey_$journeyId');
    }
  }

  /// Listen to SOS distress alerts
  void onSOSAlert(Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on('sos_alert', callback);
    }
  }

  /// Listen to location progress updates
  void onLocationChanged(Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on('location_changed', callback);
    }
  }
}
