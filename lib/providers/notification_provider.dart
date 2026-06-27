import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/socket_client_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService.instance;

  List<dynamic> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NotificationProvider() {
    // Bind real-time WebSocket SOS alert listener to populate live alerts
    SocketClientService.instance.onSOSAlert((data) {
      _notifications.insert(0, {
        'id': data['id'] ?? UniqueKey().toString(),
        'title': 'SOS Distress Alert!',
        'message': 'Emergency distress alert triggered at (${data['latitude']}, ${data['longitude']})',
        'type': 'sos',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
      notifyListeners();
    });
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    final result = await _apiService.getNotifications();
    _isLoading = false;
    if (result != null) {
      _notifications = result;
      _errorMessage = null;
    } else {
      _errorMessage = "Failed to load notifications.";
    }
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    final success = await _apiService.markNotificationsAsRead();
    if (success) {
      for (var notif in _notifications) {
        notif['isRead'] = true;
      }
      notifyListeners();
    }
  }

  Future<void> toggleRead(String id) async {
    final result = await _apiService.toggleNotificationRead(id);
    if (result != null) {
      final idx = _notifications.indexWhere((n) => n['id'] == id);
      if (idx != -1) {
        _notifications[idx] = result;
        notifyListeners();
      }
    }
  }
}
