import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static const String _tokenKey = 'jwt_auth_token';
  static const String _userKey = 'auth_user_data';

  // Singleton pattern
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  /// Retrieve current JWT token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Save JWT token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Save user profile info
  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  /// Get locally cached user info
  Future<Map<String, dynamic>?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  /// Clear auth session
  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Inject standard request headers
  Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- Auth Requests ---

  Future<Map<String, dynamic>?> register(String phone, String name, String pin, {String role = 'USER'}) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: await _headers(),
        body: jsonEncode({
          'phone': phone,
          'name': name,
          'pin': pin,
          'role': role,
        }),
      );
      if (res.statusCode == 201) {
        final body = jsonDecode(res.body);
        await saveToken(body['token']);
        await saveUser(body['user']);
        return body;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> login(String phone, String pin) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: await _headers(),
        body: jsonEncode({
          'phone': phone,
          'pin': pin,
        }),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        await saveToken(body['token']);
        await saveUser(body['user']);
        return body;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- Guardian Requests ---

  Future<List<dynamic>?> getGuardians() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/guardians'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> addGuardian(String name, String relation, String phone) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/guardians'),
        headers: await _headers(),
        body: jsonEncode({
          'name': name,
          'relation': relation,
          'phone': phone,
        }),
      );
      if (res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteGuardian(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/guardians/$id'),
        headers: await _headers(),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- Journey Requests ---

  Future<Map<String, dynamic>?> planJourney(
    String from,
    String to,
    String duration,
    String routeType,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/journeys'),
        headers: await _headers(),
        body: jsonEncode({
          'from': from,
          'to': to,
          'duration': duration,
          'routeType': routeType,
        }),
      );
      if (res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateJourneyProgress(
    String id,
    double progress, {
    String? status,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final res = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/journeys/$id'),
        headers: await _headers(),
        body: jsonEncode({
          'progress': progress,
          if (status != null) 'status': status,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>?> getJourneyHistory({int page = 1, int limit = 10}) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/journeys/history?page=$page&limit=$limit'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // Supports standardized pagination format
        if (data is Map && data.containsKey('data')) {
          return data['data'] as List<dynamic>;
        }
        return data as List<dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- SOS Requests ---

  Future<Map<String, dynamic>?> triggerSOS(double latitude, double longitude) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/sos/trigger'),
        headers: await _headers(),
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      if (res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> resolveSOS(String id) async {
    try {
      final res = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/sos/resolve/$id'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- Safety Data Requests (Crime Zones & Safe Places & Road Reports) ---

  Future<List<dynamic>?> getCrimeZones() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/safety/crime-zones'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('data')) {
          return data['data'] as List<dynamic>;
        }
        return data as List<dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>?> getSafePlaces() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/safety/safe-places'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('data')) {
          return data['data'] as List<dynamic>;
        }
        return data as List<dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>?> getRoadReports() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/safety/road-reports'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('data')) {
          return data['data'] as List<dynamic>;
        }
        return data as List<dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> createRoadReport(
    String roadName,
    String reporterName,
    double rating,
    List<String> tags,
    String comment,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/safety/road-reports'),
        headers: await _headers(),
        body: jsonEncode({
          'roadName': roadName,
          'reporterName': reporterName,
          'rating': rating,
          'tags': tags,
          'comment': comment,
        }),
      );
      if (res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- Notifications Requests ---

  Future<List<dynamic>?> getNotifications() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> markNotificationsAsRead() async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/mark-read'),
        headers: await _headers(),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> toggleNotificationRead(String id) async {
    try {
      final res = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$id'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
