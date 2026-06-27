import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import 'rate_road_screen.dart';
import 'road_reports_screen.dart';

class RoadSafetyScreen extends StatelessWidget {
  const RoadSafetyScreen({Key? key}) : super(key: key);

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
          'Road Safety Audit',
          style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientCard(
                child: Row(
                  children: [
                    const Icon(Icons.edit_road_rounded, color: Colors.white, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Crowdsourced Safety',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rate roads and share lighting, visibility or patrol statuses to protect others.',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SoftCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RateRoadScreen()),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star_rate_rounded, color: AppColors.warning, size: 36),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rate a Road', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Share safety levels of a street you just travelled.', style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 16),
              SoftCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RoadReportsScreen()),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.description_rounded, color: AppColors.primary, size: 36),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recent Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('View road safety reports submitted by the community.', style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }
}