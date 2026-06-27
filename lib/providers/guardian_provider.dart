import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GuardianProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService.instance;

  List<dynamic> _guardians = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get guardians => _guardians;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchGuardians() async {
    _isLoading = true;
    notifyListeners();
    final result = await _apiService.getGuardians();
    _isLoading = false;
    if (result != null) {
      _guardians = result;
      _errorMessage = null;
    } else {
      _errorMessage = "Failed to load guardians.";
    }
    notifyListeners();
  }

  Future<bool> addGuardian(String name, String relation, String phone) async {
    _isLoading = true;
    notifyListeners();
    final result = await _apiService.addGuardian(name, relation, phone);
    _isLoading = false;
    if (result != null) {
      _guardians.add(result);
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Failed to add guardian contact.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGuardian(String id) async {
    _isLoading = true;
    notifyListeners();
    final success = await _apiService.deleteGuardian(id);
    _isLoading = false;
    if (success) {
      _guardians.removeWhere((g) => g['id'] == id);
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Failed to delete guardian contact.";
      notifyListeners();
      return false;
    }
  }
}
