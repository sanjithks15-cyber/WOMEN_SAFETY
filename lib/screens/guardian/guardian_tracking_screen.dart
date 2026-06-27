import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_colors.dart';
import '../../services/socket_client_service.dart';

class GuardianTrackingScreen extends StatefulWidget {
  final String journeyId;
  final String wardName;

  const GuardianTrackingScreen({
    Key? key,
    required this.journeyId,
    required this.wardName,
  }) : super(key: key);

  @override
  State<GuardianTrackingScreen> createState() => _GuardianTrackingScreenState();
}

class _GuardianTrackingScreenState extends State<GuardianTrackingScreen> {
  late final MapController _mapController;
  LatLng _wardLocation = const LatLng(12.9716, 77.5946);
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _connectToSocket();
  }

  void _connectToSocket() {
    SocketClientService.instance.joinJourney(widget.journeyId);
    SocketClientService.instance.socket?.on('journey_progress', (data) {
      if (mounted) {
        setState(() {
          _isConnected = true;
          if (data['latitude'] != null && data['longitude'] != null) {
            _wardLocation = LatLng(data['latitude'], data['longitude']);
            _mapController.move(_wardLocation, 16.0);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    SocketClientService.instance.socket?.off('journey_progress');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking ${widget.wardName}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Icon(_isConnected ? Icons.wifi : Icons.wifi_off, color: _isConnected ? Colors.greenAccent : Colors.redAccent),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _wardLocation,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.samasoc.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _wardLocation,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.person_pin_circle_rounded, color: AppColors.primary, size: 40),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Live Location of ${widget.wardName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Waiting for updates via WebSocket...', style: TextStyle(color: AppColors.mutedForeground)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
