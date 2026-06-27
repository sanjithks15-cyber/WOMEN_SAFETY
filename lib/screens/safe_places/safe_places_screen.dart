import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../models/safe_place_model.dart';
import '../../providers/safety_provider.dart';
import '../journey/active_journey_screen.dart';

class SafePlacesScreen extends StatefulWidget {
  const SafePlacesScreen({Key? key}) : super(key: key);

  @override
  State<SafePlacesScreen> createState() => _SafePlacesScreenState();
}

class _SafePlacesScreenState extends State<SafePlacesScreen> {
  String _selectedCategory = 'all';
  bool _isMapView = true;
  late final MapController _mapController;
  Position? _currentPosition;
  bool _fetchingLocation = false;
  SafePlace? _selectedPlace;

  static const double _defaultLatitude = 12.9716;
  static const double _defaultLongitude = 77.5946;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SafetyProvider>().fetchSafePlaces();
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    if (_fetchingLocation) return;
    setState(() {
      _fetchingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 4),
        );
        setState(() {
          _currentPosition = position;
        });

        // Fetch live real-world safe places around user
        if (mounted) {
          context.read<SafetyProvider>().fetchSafePlaces(
            lat: position.latitude, 
            lng: position.longitude
          );
        }

        // Center map on user location
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          14.5,
        );
      }
    } catch (e) {
      debugPrint("Error fetching current position: $e");
    } finally {
      if (mounted) {
        setState(() {
          _fetchingLocation = false;
        });
      }
    }
  }

  void _reCenterMap() {
    final double lat = _currentPosition?.latitude ?? _defaultLatitude;
    final double lng = _currentPosition?.longitude ?? _defaultLongitude;
    _mapController.move(LatLng(lat, lng), 15.0);
  }

  void _callPlace(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot call $phone')),
        );
      }
    }
  }

  void _navigateToPlace(double latitude, double longitude, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveJourneyScreen(
          journey: {
            'to': name,
            'routeType': 'safest',
            'startLat': _currentPosition?.latitude ?? _defaultLatitude,
            'startLng': _currentPosition?.longitude ?? _defaultLongitude,
            'endLat': latitude,
            'endLng': longitude,
          },
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'police':
        return Icons.local_police_rounded;
      case 'hospital':
        return Icons.local_hospital_rounded;
      case 'metro':
        return Icons.subway_rounded;
      case 'petrol':
        return Icons.local_gas_station_rounded;
      case 'store':
      default:
        return Icons.local_convenience_store_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'police':
        return Colors.blue;
      case 'hospital':
        return Colors.red;
      case 'metro':
        return Colors.green;
      case 'petrol':
        return Colors.orange;
      case 'store':
      default:
        return Colors.teal;
    }
  }

  Widget _buildMapView(List<SafePlace> places) {
    final double centerLat = _currentPosition?.latitude ?? _defaultLatitude;
    final double centerLng = _currentPosition?.longitude ?? _defaultLongitude;

    final List<Marker> markers = [];

    // User location pulsing marker
    markers.add(
      Marker(
        point: LatLng(centerLat, centerLng),
        width: 60.0,
        height: 60.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
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
    );

    // Safe Places markers
    for (var place in places) {
      final catColor = _getCategoryColor(place.category);
      final catIcon = _getCategoryIcon(place.category);
      final isSelected = _selectedPlace?.id == place.id;

      markers.add(
        Marker(
          point: LatLng(place.latitude, place.longitude),
          width: isSelected ? 50.0 : 40.0,
          height: isSelected ? 50.0 : 40.0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPlace = place;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? catColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : catColor,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: catColor.withOpacity(0.4),
                    blurRadius: isSelected ? 12.0 : 6.0,
                    spreadRadius: isSelected ? 2.0 : 1.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  catIcon,
                  color: isSelected ? Colors.white : catColor,
                  size: isSelected ? 24.0 : 20.0,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(centerLat, centerLng),
              initialZoom: 14.0,
              onTap: (_, __) {
                if (_selectedPlace != null) {
                  setState(() {
                    _selectedPlace = null;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.samasoc.app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
        ),

        // Re-center FAB
        Positioned(
          right: 16,
          bottom: _selectedPlace != null ? 190 : 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onPressed: _reCenterMap,
            child: _fetchingLocation
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.my_location_rounded, size: 20),
          ),
        ),

        // Place details slide-up card
        if (_selectedPlace != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _buildPlaceDetailCard(_selectedPlace!).animate().slideY(
                  begin: 1.0,
                  end: 0.0,
                  duration: 250.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
      ],
    );
  }

  Widget _buildPlaceDetailCard(SafePlace place) {
    final catColor = _getCategoryColor(place.category);
    final catIcon = _getCategoryIcon(place.category);

    return SoftCard(
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(catIcon, color: catColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 28), // Close button offset
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            place.category.toUpperCase(),
                            style: TextStyle(
                              color: catColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (place.is24x7) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '24/7',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      place.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _navigateToPlace(place.latitude, place.longitude, place.name),
                          icon: const Icon(Icons.navigation_rounded, size: 14),
                          label: const Text('Directions'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => _callPlace(place.phone),
                          icon: const Icon(Icons.phone_rounded, size: 14),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            side: const BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPlace = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded, size: 16, color: Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<SafePlace> places) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        final catColor = _getCategoryColor(place.category);
        final catIcon = _getCategoryIcon(place.category);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: SoftCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(catIcon, color: catColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          if (place.is24x7)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '24/7',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.address,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _navigateToPlace(place.latitude, place.longitude, place.name),
                            icon: const Icon(Icons.navigation_rounded, size: 16),
                            label: const Text('Directions'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => _callPlace(place.phone),
                            icon: const Icon(Icons.phone_rounded, size: 16),
                            label: const Text('Call'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              side: const BorderSide(color: AppColors.primary),
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SafetyProvider>();
    final List<SafePlace> allPlaces = provider.safePlaces
        .map((p) => SafePlace.fromMap(p as Map<String, dynamic>))
        .toList();

    final List<SafePlace> filteredPlaces = _selectedCategory == 'all'
        ? allPlaces
        : allPlaces.where((p) => p.category.toLowerCase() == _selectedCategory).toList();

    final categories = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Police', 'value': 'police'},
      {'label': 'Hospital', 'value': 'hospital'},
      {'label': 'Metro', 'value': 'metro'},
      {'label': 'Petrol', 'value': 'petrol'},
      {'label': '24/7 Stores', 'value': 'store'},
    ];

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
          'Safe Havens Nearby',
          style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isMapView ? Icons.list_alt_rounded : Icons.map_rounded,
              color: AppColors.primary,
            ),
            tooltip: _isMapView ? 'List View' : 'Map View',
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
                _selectedPlace = null; // Reset selection on toggle
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Floating Categories bar
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == cat['value'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat['value']!;
                        _selectedPlace = null; // Clear detail card if filter changes
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.secondary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.secondary : AppColors.border,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          cat['label']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.foreground,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Dynamic layout (Map View vs List View)
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredPlaces.isEmpty
                      ? const Center(
                          child: Text(
                            'No safe places found in this category.',
                            style: TextStyle(color: AppColors.mutedForeground),
                          ),
                        )
                      : Padding(
                          padding: _isMapView 
                              ? const EdgeInsets.fromLTRB(16, 0, 16, 16)
                              : EdgeInsets.zero,
                          child: _isMapView
                              ? _buildMapView(filteredPlaces)
                              : _buildListView(filteredPlaces),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}