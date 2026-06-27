import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/sos_provider.dart';
import '../../providers/guardian_provider.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../helplines_screen.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({Key? key}) : super(key: key);

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with SingleTickerProviderStateMixin {
  bool _holding = false;
  double _progress = 0.0;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startHold() async {
    final sosProvider = context.read<SOSProvider>();
    if (sosProvider.isSOSActive) return;

    setState(() {
      _holding = true;
      _progress = 0.0;
    });
    
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 100, amplitude: 128);
      }
    } catch (e) {
      debugPrint("Vibration error: $e");
    }

    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _timer?.cancel();
          _triggerSOS();
        }
      });
    });
  }

  void _stopHold() {
    _timer?.cancel();
    setState(() {
      _holding = false;
      _progress = 0.0;
    });
  }

  void _triggerSOS() async {
    final sosProvider = context.read<SOSProvider>();
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 1000, amplitude: 255);
      }
    } catch (e) {
      debugPrint("Vibration error: $e");
    }

    // Attempt to acquire real GPS location
    double latitude = 12.9716;
    double longitude = 77.5946;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 4),
        );
        latitude = position.latitude;
        longitude = position.longitude;
      }
    } catch (e) {
      debugPrint("Could not retrieve GPS coordinates: $e");
    }

    final success = await sosProvider.triggerSOS(latitude, longitude);

    // Call Guardian directly
    try {
      final guardianProvider = context.read<GuardianProvider>();
      if (guardianProvider.guardians.isNotEmpty) {
        final String phone = guardianProvider.guardians.first['phone'];
        await FlutterPhoneDirectCaller.callNumber(phone);
      }
    } catch (e) {
      debugPrint("Could not launch dialer: $e");
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                color: success ? AppColors.success : AppColors.destructive,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(success ? 'SOS Sent Successfully' : 'Alert Trigger Failed'),
              ),
            ],
          ),
          content: Text(
            success
                ? 'Your emergency circle has been sent your live location ($latitude, $longitude) and distress signal.'
                : 'Could not contact safety server. Please call emergency services directly.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _resolveSOS() async {
    final sosProvider = context.read<SOSProvider>();
    final success = await sosProvider.resolveSOS();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'SOS alert resolved successfully.' : 'Failed to resolve SOS alert.'),
          backgroundColor: success ? AppColors.success : AppColors.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sosProvider = context.watch<SOSProvider>();
    final isActive = sosProvider.isSOSActive;

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
          'Emergency SOS',
          style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isActive
                    ? 'EMERGENCY SOS IS ACTIVE'
                    : 'Hold center button for 3 seconds to trigger emergency alert.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive ? AppColors.destructive : AppColors.mutedForeground,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(),
              const Spacer(),

              // Center hold to trigger SOS or Tap to Resolve button
              Center(
                child: isActive
                    ? GestureDetector(
                        onTap: _resolveSOS,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulse rings
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 180 + (_pulseController.value * 50),
                                  height: 180 + (_pulseController.value * 50),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.destructive.withOpacity(0.2 * (1 - _pulseController.value)),
                                  ),
                                );
                              },
                            ),
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: AppColors.destructive, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.destructive.withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: AppColors.destructive, size: 48),
                                    SizedBox(height: 8),
                                    Text(
                                      'RESOLVE\nALERT',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.destructive,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTapDown: (_) => _startHold(),
                        onTapUp: (_) => _stopHold(),
                        onTapCancel: () => _stopHold(),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulse rings
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 180 + (_pulseController.value * 40),
                                  height: 180 + (_pulseController.value * 40),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.destructive.withOpacity(0.15 * (1 - _pulseController.value)),
                                  ),
                                );
                              },
                            ),
                            
                            // Progress ring
                            SizedBox(
                              width: 170,
                              height: 170,
                              child: CircularProgressIndicator(
                                value: _progress,
                                strokeWidth: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.destructive),
                              ),
                            ),

                            // Central button
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.destructiveGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.destructive.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.emergency_rounded, color: Colors.white, size: 48),
                                    const SizedBox(height: 6),
                                    Text(
                                      _holding ? 'HOLDING...' : 'SOS',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const Spacer(),

              // Quick links cards
              Row(
                children: [
                  Expanded(
                    child: SoftCard(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Dead Man Switch set for 15 mins check-in.')),
                        );
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.timer_rounded, color: AppColors.secondary, size: 28),
                          SizedBox(height: 8),
                          Text('Dead Man Switch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SoftCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelplinesScreen()),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.phone_in_talk_rounded, color: AppColors.primary, size: 28),
                          SizedBox(height: 8),
                          Text('Quick Helplines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}