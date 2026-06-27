import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  GeocodingService._();

  /// Fetches location suggestions from Photon geocoding API based on a query.
  /// Biases results to Bengaluru coordinates (12.9716, 77.5946).
  static Future<List<String>> getSuggestions(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 3) return const [];

    final url = Uri.parse(
      'https://photon.komoot.io/api/?q=${Uri.encodeComponent(cleanQuery)}&lat=12.9716&lon=77.5946&limit=5'
    );

    try {
      final response = await http.get(url, headers: {'User-Agent': 'SafeHerHackathonApp/1.0'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> features = data['features'] ?? [];
        final List<String> suggestions = [];

        for (var feature in features) {
          final props = feature['properties'] ?? {};
          final name = props['name'] ?? '';
          final street = props['street'] ?? '';
          final city = props['city'] ?? '';
          final state = props['state'] ?? '';

          String description = name;
          if (street.isNotEmpty && street != name) {
            description += ', $street';
          }
          if (city.isNotEmpty) {
            description += ', $city';
          } else if (state.isNotEmpty) {
            description += ', $state';
          }

          if (description.isNotEmpty && !suggestions.contains(description)) {
            suggestions.add(description);
          }
        }
        return suggestions;
      }
    } catch (e) {
      debugPrint('Geocoding search failed: $e');
    }
    return const [];
  }

  /// Resolves an address string into geographical coordinates using Photon API.
  static Future<LatLng?> getCoordinates(String address) async {
    final cleanAddress = address.trim();
    if (cleanAddress.isEmpty) return null;

    final url = Uri.parse(
      'https://photon.komoot.io/api/?q=${Uri.encodeComponent(cleanAddress)}&limit=1'
    );

    try {
      final response = await http.get(url, headers: {'User-Agent': 'SafeHerHackathonApp/1.0'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> features = data['features'] ?? [];
        if (features.isNotEmpty) {
          final geometry = features[0]['geometry'] ?? {};
          final List<dynamic> coords = geometry['coordinates'] ?? [];
          if (coords.length >= 2) {
            // Photon returns coordinates as [longitude, latitude]
            final double lon = coords[0] as double;
            final double lat = coords[1] as double;
            return LatLng(lat, lon);
          }
        }
      }
    } catch (e) {
      debugPrint('Resolving coordinates failed: $e');
    }
    return null;
  }

  /// Retrieves road-following route points between two locations using OSRM API.
  static Future<List<LatLng>> getRoutePoints(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson'
    );

    try {
      final response = await http.get(url, headers: {'User-Agent': 'SafeHerHackathonApp/1.0'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> routes = data['routes'] ?? [];
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry'] ?? {};
          final List<dynamic> coords = geometry['coordinates'] ?? [];
          final List<LatLng> points = [];

          for (var coord in coords) {
            if (coord is List && coord.length >= 2) {
              final double lon = coord[0] as double;
              final double lat = coord[1] as double;
              points.add(LatLng(lat, lon));
            }
          }
          return points;
        }
      }
    } catch (e) {
      debugPrint('OSRM routing request failed: $e');
    }
    // Fallback to straight line if routing service fails
    return [start, end];
  }

  /// Retrieves alternative route options between start and end.
  /// If OSRM's alternatives parameter does not return distinct paths,
  /// it calculates a detour waypoint perpendicular to the midpoint
  /// to force a secondary alternative route.
  static Future<Map<String, List<LatLng>>> getRouteOptions(LatLng start, LatLng end) async {
    // 1. Get primary (fastest) route
    final primaryRoute = await getRoutePoints(start, end);
    List<LatLng> altRoute = [];

    // 2. Try fetching OSRM alternatives
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson&alternatives=true'
    );

    try {
      final response = await http.get(url, headers: {'User-Agent': 'SafeHerHackathonApp/1.0'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> routes = data['routes'] ?? [];
        if (routes.length > 1) {
          final geometry = routes[1]['geometry'] ?? {};
          final List<dynamic> coords = geometry['coordinates'] ?? [];
          final List<LatLng> pts = [];
          for (var coord in coords) {
            if (coord is List && coord.length >= 2) {
              final double lon = coord[0] as double;
              final double lat = coord[1] as double;
              pts.add(LatLng(lat, lon));
            }
          }
          altRoute = pts;
        }
      }
    } catch (e) {
      debugPrint('OSRM routing alternatives request failed: $e');
    }

    // 3. Detour fallback if alternative route is empty or identical
    if (altRoute.isEmpty || _isSameRoute(primaryRoute, altRoute)) {
      final double midLat = (start.latitude + end.latitude) / 2;
      final double midLon = (start.longitude + end.longitude) / 2;
      final double dy = end.latitude - start.latitude;
      final double dx = end.longitude - start.longitude;
      
      // Detour offset: shift perpendicular to the general direction of travel by ~15%
      final double offsetX = -dy * 0.15;
      final double offsetY = dx * 0.15;
      final LatLng detour = LatLng(midLat + offsetY, midLon + offsetX);

      final detourUrl = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${detour.longitude},${detour.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson'
      );

      try {
        final response = await http.get(detourUrl, headers: {'User-Agent': 'SafeHerHackathonApp/1.0'});
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> routes = data['routes'] ?? [];
          if (routes.isNotEmpty) {
            final geometry = routes[0]['geometry'] ?? {};
            final List<dynamic> coords = geometry['coordinates'] ?? [];
            final List<LatLng> detourPoints = [];
            for (var coord in coords) {
              if (coord is List && coord.length >= 2) {
                final double lon = coord[0] as double;
                final double lat = coord[1] as double;
                detourPoints.add(LatLng(lat, lon));
              }
            }
            altRoute = detourPoints;
          }
        }
      } catch (e) {
        debugPrint('Detour OSRM routing failed: $e');
      }
    }

    // If still empty, fallback to duplicating the primary route
    if (altRoute.isEmpty) {
      altRoute = List.from(primaryRoute);
    }

    return {
      'fastest': primaryRoute,
      'safest': altRoute,
    };
  }

  static bool _isSameRoute(List<LatLng> r1, List<LatLng> r2) {
    if (r1.length != r2.length) return false;
    for (int i = 0; i < r1.length; i++) {
      if ((r1[i].latitude - r2[i].latitude).abs() > 0.0001 ||
          (r1[i].longitude - r2[i].longitude).abs() > 0.0001) {
        return false;
      }
    }
    return true;
  }
}
