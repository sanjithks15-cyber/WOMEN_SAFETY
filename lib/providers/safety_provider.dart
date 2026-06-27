import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/geocoding_service.dart';

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

  Future<void> fetchSafePlaces({double? lat, double? lng}) async {
    _isLoading = true;
    notifyListeners();
    
    if (lat != null && lng != null) {
      // Use live Overpass API for real nearby safe places
      final result = await GeocodingService.fetchNearbySafePlaces(lat, lng);
      _safePlaces = result;
      _errorMessage = null;
    } else {
      // Fallback to mock data from backend if no GPS
      final result = await _apiService.getSafePlaces();
      if (result != null) {
        _safePlaces = result;
        _errorMessage = null;
      } else {
        _errorMessage = "Failed to load safe places.";
      }
    }
    
    _isLoading = false;
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
