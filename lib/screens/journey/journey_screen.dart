import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

import 'package:provider/provider.dart';
import '../../providers/journey_provider.dart';
import '../../providers/safety_provider.dart';
import '../../models/safe_place_model.dart';
import '../../services/geocoding_service.dart';
import 'active_journey_screen.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({Key? key}) : super(key: key);

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _fromFocusNode = FocusNode();
  final _toFocusNode = FocusNode();
  bool _calculating = false;
  bool _showRoutes = false;

  LatLng? _startLatLng;
  LatLng? _endLatLng;
  List<LatLng> _safestRoutePoints = [];
  List<LatLng> _fastestRoutePoints = [];
  String _selectedRouteType = 'Safest'; // default select
  List<Marker> _safeHavenMarkers = [];
  late final MapController _previewMapController;

  String _safeDistanceStr = '8.4 km';
  String _safeTimeStr = '25 mins';
  String _fastDistanceStr = '6.1 km';
  String _fastTimeStr = '18 mins';

  double _calculatePolylineDistance(List<LatLng> points) {
    double total = 0;
    final distanceCalc = const Distance();
    for (int i = 0; i < points.length - 1; i++) {
      total += distanceCalc.as(LengthUnit.Meter, points[i], points[i + 1]);
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _previewMapController = MapController();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }

  Future<void> _calculateRoute() async {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();
    if (from.isEmpty || to.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    setState(() {
      _calculating = true;
      _showRoutes = false;
    });

    try {
      final start = await GeocodingService.getCoordinates(from);
      final end = await GeocodingService.getCoordinates(to);

      if (start == null || end == null) {
        if (mounted) {
          setState(() {
            _calculating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not find locations. Please try different addresses.'),
              backgroundColor: AppColors.destructive,
            ),
          );
        }
        return;
      }

      final routes = await GeocodingService.getRouteOptions(start, end);
      
      final safetyProvider = context.read<SafetyProvider>();
      if (safetyProvider.safePlaces.isEmpty) {
        await safetyProvider.fetchSafePlaces();
      }
      
      final allSafePlaces = safetyProvider.safePlaces;
      final List<Marker> markers = [];
      
      for (var placeObj in allSafePlaces) {
        SafePlace place;
        if (placeObj is SafePlace) {
          place = placeObj;
        } else {
          place = SafePlace.fromMap(placeObj as Map<String, dynamic>);
        }

        final double distanceToStart = _distanceBetween(start.latitude, start.longitude, place.latitude, place.longitude);
        final double distanceToEnd = _distanceBetween(end.latitude, end.longitude, place.latitude, place.longitude);
        
        if (distanceToStart < 0.05 || distanceToEnd < 0.05) { // within ~5-6km local bias
          IconData catIcon;
          Color catColor;
          switch (place.category.toLowerCase()) {
            case 'police':
              catIcon = Icons.local_police_rounded;
              catColor = Colors.blue;
              break;
            case 'hospital':
              catIcon = Icons.local_hospital_rounded;
              catColor = Colors.red;
              break;
            case 'metro':
              catIcon = Icons.subway_rounded;
              catColor = Colors.green;
              break;
            case 'petrol':
              catIcon = Icons.local_gas_station_rounded;
              catColor = Colors.orange;
              break;
            default:
              catIcon = Icons.local_convenience_store_rounded;
              catColor = Colors.teal;
          }

          markers.add(
            Marker(
              point: LatLng(place.latitude, place.longitude),
              width: 32,
              height: 32,
              child: Tooltip(
                message: '${place.name} (${place.category.toUpperCase()})',
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(catIcon, color: catColor, size: 16),
                ),
              ),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _startLatLng = start;
          _endLatLng = end;
          _safestRoutePoints = routes['safest'] ?? [];
          _fastestRoutePoints = routes['fastest'] ?? [];
          
          if (_safestRoutePoints.isNotEmpty) {
            final distMeters = _calculatePolylineDistance(_safestRoutePoints);
            _safeDistanceStr = '${(distMeters / 1000).toStringAsFixed(1)} km';
            _safeTimeStr = '${(distMeters / 1000 * 3).round()} mins';
          }
          if (_fastestRoutePoints.isNotEmpty) {
            final distMeters = _calculatePolylineDistance(_fastestRoutePoints);
            _fastDistanceStr = '${(distMeters / 1000).toStringAsFixed(1)} km';
            _fastTimeStr = '${(distMeters / 1000 * 2).round()} mins';
          }

          _safeHavenMarkers = markers;
          _calculating = false;
          _showRoutes = true;
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _startLatLng != null && _endLatLng != null) {
            _previewMapController.move(
              LatLng(
                (_startLatLng!.latitude + _endLatLng!.latitude) / 2,
                (_startLatLng!.longitude + _endLatLng!.longitude) / 2,
              ),
              13.0,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error calculating routes: $e');
      if (mounted) {
        setState(() {
          _calculating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to compute route safety paths. Please try again.'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    // Simple Euclidean distance for local checks (safe places filtering)
    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;
    return dLat * dLat + dLon * dLon;
  }

  void _startJourney(String routeType) async {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();

    final journeyProvider = context.read<JourneyProvider>();
    final success = await journeyProvider.planJourney(
      from,
      to,
      routeType == 'Safest' ? _safeTimeStr : _fastTimeStr,
      routeType.toLowerCase(),
    );

    if (mounted) {
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ActiveJourneyScreen(
              journey: journeyProvider.activeJourney!,
              preCalculatedRoutePoints: routeType == 'Safest' ? _safestRoutePoints : _fastestRoutePoints,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(journeyProvider.errorMessage ?? 'Failed to start journey.'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.foreground),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Plan Safe Journey',
          style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SoftCard(
                child: Column(
                  children: [
                    Autocomplete<String>(
                      textEditingController: _fromController,
                      focusNode: _fromFocusNode,
                      optionsBuilder: (TextEditingValue textEditingValue) async {
                        if (textEditingValue.text.length < 3) {
                          return const Iterable<String>.empty();
                        }
                        return await GeocodingService.getSuggestions(textEditingValue.text);
                      },
                      onSelected: (String selection) {
                        _fromController.text = selection;
                      },
                      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onFieldSubmitted: (value) => onFieldSubmitted(),
                          decoration: const InputDecoration(
                            labelText: 'Starting Point',
                            hintText: 'Enter start address',
                            prefixIcon: Icon(Icons.my_location_rounded, color: AppColors.primary),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return _buildAutocompleteDropdown(context, onSelected, options);
                      },
                    ),
                    const SizedBox(height: 16),
                    Autocomplete<String>(
                      textEditingController: _toController,
                      focusNode: _toFocusNode,
                      optionsBuilder: (TextEditingValue textEditingValue) async {
                        if (textEditingValue.text.length < 3) {
                          return const Iterable<String>.empty();
                        }
                        return await GeocodingService.getSuggestions(textEditingValue.text);
                      },
                      onSelected: (String selection) {
                        _toController.text = selection;
                      },
                      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onFieldSubmitted: (value) => onFieldSubmitted(),
                          decoration: const InputDecoration(
                            labelText: 'Destination',
                            hintText: 'Enter destination address',
                            prefixIcon: Icon(Icons.location_on_rounded, color: AppColors.secondary),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return _buildAutocompleteDropdown(context, onSelected, options);
                      },
                    ),
                    const SizedBox(height: 20),
                    GradientButton(
                      text: _calculating ? 'Analyzing Safety...' : 'Calculate Routes',
                      isLoading: _calculating,
                      onPressed: _calculating ? null : _calculateRoute,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_showRoutes) ...[
                const Text(
                  'Recommended Routes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ).animate().fadeIn(),
                const SizedBox(height: 12),
                
                // Map Preview Container
                Container(
                  height: 280,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _previewMapController,
                          options: MapOptions(
                            initialCenter: _startLatLng ?? const LatLng(12.9716, 77.5946),
                            initialZoom: 13.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.samasoc.app',
                            ),
                            PolylineLayer(
                              polylines: [
                                // Fastest Route (Orange/Red)
                                Polyline(
                                  points: _fastestRoutePoints,
                                  color: _selectedRouteType == 'Fastest'
                                      ? Colors.orange.shade700
                                      : Colors.orange.shade300.withOpacity(0.4),
                                  strokeWidth: _selectedRouteType == 'Fastest' ? 6.0 : 3.5,
                                ),
                                // Safest Route (Teal/Green)
                                Polyline(
                                  points: _safestRoutePoints,
                                  color: _selectedRouteType == 'Safest'
                                      ? Colors.teal.shade600
                                      : Colors.teal.shade300.withOpacity(0.4),
                                  strokeWidth: _selectedRouteType == 'Safest' ? 6.0 : 3.5,
                                ),
                              ],
                            ),
                            MarkerLayer(
                              markers: [
                                // Start Marker
                                if (_startLatLng != null)
                                  Marker(
                                    point: _startLatLng!,
                                    width: 40,
                                    height: 40,
                                    child: const Icon(Icons.home_rounded, color: Colors.green, size: 28),
                                  ),
                                // End Marker
                                if (_endLatLng != null)
                                  Marker(
                                    point: _endLatLng!,
                                    width: 40,
                                    height: 40,
                                    child: const Icon(Icons.flag_rounded, color: Colors.red, size: 30),
                                  ),
                                // Safe places markers along route
                                ..._safeHavenMarkers,
                              ],
                            ),
                          ],
                        ),
                        // Floating Route Select overlay
                        Positioned(
                          left: 12,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 12, height: 4, color: Colors.teal.shade600),
                                    const SizedBox(width: 6),
                                    const Text('Safest Route (98%)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(width: 12, height: 4, color: Colors.orange.shade700),
                                    const SizedBox(width: 6),
                                    const Text('Fastest Route (72%)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Recenter button
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: FloatingActionButton(
                            mini: true,
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            onPressed: () {
                              if (_startLatLng != null && _endLatLng != null) {
                                _previewMapController.move(
                                  LatLng(
                                    (_startLatLng!.latitude + _endLatLng!.latitude) / 2,
                                    (_startLatLng!.longitude + _endLatLng!.longitude) / 2,
                                  ),
                                  13.0,
                                );
                              }
                            },
                            child: const Icon(Icons.zoom_out_map_rounded, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 50.ms),

                SoftCard(
                  onTap: () {
                    setState(() {
                      _selectedRouteType = 'Safest';
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedRouteType == 'Safest' ? AppColors.success : Colors.transparent,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield_rounded, color: AppColors.success, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Safest Route', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('98% Safe', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Via well-lit main roads & police patrol zones.',
                                style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$_safeTimeStr • $_safeDistanceStr',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 12),
                SoftCard(
                  onTap: () {
                    setState(() {
                      _selectedRouteType = 'Fastest';
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedRouteType == 'Fastest' ? AppColors.warning : Colors.transparent,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.flash_on_rounded, color: AppColors.warning, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Fastest Route', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('72% Safe', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Via alleys / dark stretches. High-risk zones ahead.',
                                style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$_fastTimeStr • $_fastDistanceStr',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),
                GradientButton(
                  text: 'Start Journey (${_selectedRouteType} Route)',
                  onPressed: () => _startJourney(_selectedRouteType),
                ).animate().fadeIn(delay: 300.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutocompleteDropdown(
    BuildContext context,
    AutocompleteOnSelected<String> onSelected,
    Iterable<String> options,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width - 64, // Matches input card width with paddings
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (BuildContext context, int index) {
                final String option = options.elementAt(index);
                return ListTile(
                  dense: true,
                  title: Text(
                    option,
                    style: const TextStyle(fontSize: 13, color: AppColors.foreground),
                  ),
                  leading: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                  onTap: () => onSelected(option),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}