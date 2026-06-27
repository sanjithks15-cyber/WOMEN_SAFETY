import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SafetyProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService.instance;

  List<dynamic> _crimeZones = [];
  List<dynamic> _safePlaces = [];
  List<dynamic> _roadReports = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get crimeZones => _crimeZones;
  List<dynamic> get safePlaces => _safePlaces;
  List<dynamic> get roadReports => _roadReports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCrimeZones() async {
    _isLoading = true;
    notifyListeners();
    final result = await _apiService.getCrimeZones();
    _isLoading = false;
    if (result != null) {
      _crimeZones = result;
      _errorMessage = null;
    } else {
      _errorMessage = "Failed to load crime zones.";
    }
    notifyListeners();
  }

  Future<void> fetchSafePlaces() async {
    _isLoading = true;
    notifyListeners();
    final result = await _apiService.getSafePlaces();
    _isLoading = false;
    if (result != null) {
      _safePlaces = result;
      _errorMessage = null;
    } else {
      _errorMessage = "Failed to load safe places.";
    }
    notifyListeners();
  }

  Future<void> fetchRoadReports() async {
    _isLoading = true;
    notifyListeners();
    final result = await _apiService.getRoadReports();
    _isLoading = false;
    if (result != null) {
      _roadReports = result;
      _errorMessage = null;
    } else {
      _errorMessage = "Failed to load road safety reports.";
    }
    notifyListeners();
  }

  Future<bool> createRoadReport(
    String roadName,
    String reporterName,
    double rating,
    List<String> tags,
    String comment,
  ) async {
    _isLoading = true;
    notifyListeners();
    final result = await _apiService.createRoadReport(roadName, reporterName, rating, tags, comment);
    _isLoading = false;
    if (result != null) {
      _roadReports.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }
}
