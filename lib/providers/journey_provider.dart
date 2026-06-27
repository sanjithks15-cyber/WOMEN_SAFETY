import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/socket_client_service.dart';

class JourneyProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService.instance;

  Map<String, dynamic>? _activeJourney;
  List<dynamic> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get activeJourney => _activeJourney;
  List<dynamic> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> planJourney(String from, String to, String duration, String routeType) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.planJourney(from, to, duration, routeType);
    _isLoading = false;

    if (result != null) {
      _activeJourney = result;
      // Connect to WebSocket room for this journey to stream real-time updates
      SocketClientService.instance.joinJourney(_activeJourney!['id']);
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Failed to create journey. Make sure you don't have another active journey.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProgress(double progress, {String? status, double? latitude, double? longitude}) async {
    if (_activeJourney == null) return false;

    final journeyId = _activeJourney!['id'];
    final result = await _apiService.updateJourneyProgress(
      journeyId,
      progress,
      status: status,
      latitude: latitude,
      longitude: longitude,
    );

    if (result != null) {
      _activeJourney = result;
      if (status == 'COMPLETED' || status == 'CANCELLED') {
        _activeJourney = null;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.getJourneyHistory();
    _isLoading = false;

    if (result != null) {
      _history = result;
      _errorMessage = null;
    } else {
      _errorMessage = "Failed to load journey history.";
    }
    notifyListeners();
  }
}
