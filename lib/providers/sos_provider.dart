import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SOSProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService.instance;

  bool _isSOSActive = false;
  Map<String, dynamic>? _activeAlert;
  String? _errorMessage;
  bool _isLoading = false;

  bool get isSOSActive => _isSOSActive;
  Map<String, dynamic>? get activeAlert => _activeAlert;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<bool> triggerSOS(double latitude, double longitude) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.triggerSOS(latitude, longitude);
    _isLoading = false;

    if (result != null) {
      _activeAlert = result;
      _isSOSActive = true;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Failed to trigger SOS alert on server.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> resolveSOS() async {
    if (_activeAlert == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final alertId = _activeAlert!['id'];
    final result = await _apiService.resolveSOS(alertId);
    _isLoading = false;

    if (result != null) {
      _activeAlert = null;
      _isSOSActive = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Failed to resolve SOS alert on server.";
      notifyListeners();
      return false;
    }
  }
}
