import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/journey_provider.dart';
import '../../services/geocoding_service.dart';

class ActiveJourneyScreen extends StatefulWidget {
  final Map<String, dynamic> journey;
  final List<LatLng>? preCalculatedRoutePoints;

  const ActiveJourneyScreen({
    Key? key,
    required this.journey,
    this.preCalculatedRoutePoints,
  }) : super(key: key);

  @override
  State<ActiveJourneyScreen> createState() => _ActiveJourneyScreenState();
}

class _ActiveJourneyScreenState extends State<ActiveJourneyScreen> {
  late final MapController _mapController;
  Timer? _simulationTimer;
  
  LatLng? _startLatLng;
  LatLng? _endLatLng;
  LatLng? _currentLatLng;
  List<LatLng> _routePoints = [];
  
  int _currentRouteIndex = 0;
  double _progress = 0.0;
  bool _loadingRoute = true;
  bool _isSimulationRunning = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadRouteDetails();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRouteDetails() async {
    // If we already have pre-calculated points, use them directly
    if (widget.preCalculatedRoutePoints != null && widget.preCalculatedRoutePoints!.isNotEmpty) {
      final points = widget.preCalculatedRoutePoints!;
      if (mounted) {
        setState(() {
          _startLatLng = points.first;
          _endLatLng = points.last;
          _currentLatLng = points.first;
          _routePoints = points;
          _loadingRoute = false;
        });
        _startMovementSimulation();
      }
      return;
    }

    final fromAddress = widget.journey['from'] ?? '';
    final toAddress = widget.journey['to'] ?? '';

    // Step 1: Get coordinates (either provided directly or via geocoding)
    LatLng? start;
    if (widget.journey['startLat'] != null && widget.journey['startLng'] != null) {
      start = LatLng(widget.journey['startLat'], widget.journey['startLng']);
    } else {
      start = await GeocodingService.getCoordinates(fromAddress);
    }

    LatLng? end;
    if (widget.journey['endLat'] != null && widget.journey['endLng'] != null) {
      end = LatLng(widget.journey['endLat'], widget.journey['endLng']);
    } else {
      end = await GeocodingService.getCoordinates(toAddress);
    }

    if (start == null || end == null) {
      if (mounted) {
        setState(() {
          _loadingRoute = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not calculate coordinates for addresses. Drawing default direct route.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }

    // Step 2: Query OSRM to get street-following path points
    final route = await GeocodingService.getRoutePoints(start, end);

    if (mounted) {
      setState(() {
        _startLatLng = start;
        _endLatLng = end;
        _currentLatLng = start;
        _routePoints = route;
        _loadingRoute = false;
      });

      // Step 3: Start the movement simulation
      _startMovementSimulation();
    }
  }

  void _startMovementSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      if (!_isSimulationRunning || _routePoints.isEmpty) return;

      if (_currentRouteIndex >= _routePoints.length - 1) {
        // Arrived at destination
        timer.cancel();
        setState(() {
          _progress = 1.0;
          _currentLatLng = _endLatLng;
        });
        
        // Auto-complete or notify
        final journeyProvider = context.read<JourneyProvider>();
        await journeyProvider.updateProgress(1.0, status: 'COMPLETED');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have safely arrived at your destination! Live location sharing ended.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        return;
      }

      // Step forward on OSRM polyline
      setState(() {
        _currentRouteIndex++;
        _currentLatLng = _routePoints[_currentRouteIndex];
        _progress = _currentRouteIndex / (_routePoints.length - 1);
      });

      // Sync progress & coordinates to backend via WebSocket / HTTP
      final journeyProvider = context.read<JourneyProvider>();
      await journeyProvider.updateProgress(
        _progress,
        latitude: _currentLatLng!.latitude,
        longitude: _currentLatLng!.longitude,
      );

      // Smoothly move the map to keep user centered
      _mapController.move(_currentLatLng!, 15.0);
    });
  }

  void _toggleSimulation() {
    setState(() {
      _isSimulationRunning = !_isSimulationRunning;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSimulationRunning ? 'Simulation resumed' : 'Simulation paused'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _cancelJourney() async {
    _simulationTimer?.cancel();
    final journeyProvider = context.read<JourneyProvider>();
    final success = await journeyProvider.updateProgress(_progress, status: 'CANCELLED');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Journey cancelled.' : 'Failed to cancel journey.'),
          backgroundColor: AppColors.destructive,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _completeJourney() async {
    _simulationTimer?.cancel();
    final journeyProvider = context.read<JourneyProvider>();
    final success = await journeyProvider.updateProgress(1.0, status: 'COMPLETED');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journey completed successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _triggerSafeCheckIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Safe check-in sent to guardians! "I am on my way & safe."'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeType = widget.journey['routeType'] ?? 'safest';

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
          'Live Journey Tracking',
          style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_loadingRoute && _routePoints.isNotEmpty)
            IconButton(
              icon: Icon(
                _isSimulationRunning ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              onPressed: _toggleSimulation,
            ),
        ],
      ),
      body: SafeArea(
        child: _loadingRoute
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Calculating live route path from OSRM...'),
                  ],
                ),
              )
            : Column(
                children: [
                  // Map Frame
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _currentLatLng ?? const LatLng(12.9716, 77.5946),
                                initialZoom: 15.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.samasoc.app',
                                ),
                                if (_routePoints.isNotEmpty)
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: _routePoints,
                                        color: routeType.toLowerCase() == 'safest'
                                            ? Colors.teal.shade600
                                            : Colors.orange.shade700,
                                        strokeWidth: 5.5,
                                      ),
                                    ],
                                  ),
                                MarkerLayer(
                                  markers: [
                                    // Start Pin
                                    if (_startLatLng != null)
                                      Marker(
                                        point: _startLatLng!,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(Icons.home_rounded, color: Colors.green, size: 30),
                                      ),
                                    // Destination Pin
                                    if (_endLatLng != null)
                                      Marker(
                                        point: _endLatLng!,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(Icons.flag_rounded, color: Colors.red, size: 32),
                                      ),
                                    // Current User Pin
                                    if (_currentLatLng != null)
                                      Marker(
                                        point: _currentLatLng!,
                                        width: 50,
                                        height: 50,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.primary.withOpacity(0.2),
                                              ),
                                            ),
                                            Container(
                                              width: 14,
                                              height: 14,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),

                            // Floating Re-Center Button
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: FloatingActionButton(
                                mini: true,
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                onPressed: () {
                                  if (_currentLatLng != null) {
                                    _mapController.move(_currentLatLng!, 15.0);
                                  }
                                },
                                child: const Icon(Icons.my_location_rounded, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom detail card showing journey metrics and simulation control
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.navigation_rounded, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Live Location Sharing Active',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      'Travelling via ${routeType.toUpperCase()} route',
                                      style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${(_progress * 100).toInt()}% Done',
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _triggerSafeCheckIn,
                                  icon: const Icon(Icons.done_all_rounded, size: 16),
                                  label: const Text('Check-in'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    foregroundColor: AppColors.secondary,
                                    side: const BorderSide(color: AppColors.secondary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _progress >= 1.0 ? _completeJourney : _cancelJourney,
                                  icon: Icon(
                                    _progress >= 1.0 ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                                    size: 16,
                                  ),
                                  label: Text(_progress >= 1.0 ? 'Finish' : 'Cancel'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    backgroundColor: _progress >= 1.0 ? AppColors.success : AppColors.destructive,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
