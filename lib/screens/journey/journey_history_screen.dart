import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../models/journey_model.dart';
import '../../providers/journey_provider.dart';

class JourneyHistoryScreen extends StatefulWidget {
  const JourneyHistoryScreen({Key? key}) : super(key: key);

  @override
  State<JourneyHistoryScreen> createState() => _JourneyHistoryScreenState();
}

class _JourneyHistoryScreenState extends State<JourneyHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JourneyProvider>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JourneyProvider>();
    final List<Journey> journeys = provider.history
        .map((j) => Journey.fromMap(j as Map<String, dynamic>))
        .toList();

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
          'Journey History',
          style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : journeys.isEmpty
                ? const Center(
                    child: Text(
                      'No journey history found.',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: journeys.length,
                    itemBuilder: (context, index) {
                      final j = journeys[index];
                      Color statusColor;
                      IconData statusIcon;

                      switch (j.status.toLowerCase()) {
                        case 'completed':
                          statusColor = AppColors.success;
                          statusIcon = Icons.check_circle_outline_rounded;
                          break;
                        case 'sos':
                          statusColor = AppColors.destructive;
                          statusIcon = Icons.emergency_rounded;
                          break;
                        case 'cancelled':
                          statusColor = Colors.grey;
                          statusIcon = Icons.cancel_outlined;
                          break;
                        default:
                          statusColor = AppColors.primary;
                          statusIcon = Icons.directions_run_rounded;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: SoftCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${j.date} • ${j.time}',
                                    style: const TextStyle(
                                      color: AppColors.mutedForeground,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(statusIcon, color: statusColor, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          j.status.toUpperCase(),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.radio_button_checked_rounded, color: AppColors.primary, size: 16),
                                      Container(width: 2, height: 20, color: Colors.grey.shade300),
                                      const Icon(Icons.location_on_rounded, color: AppColors.secondary, size: 16),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          j.from,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          j.to,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Route: ${j.routeType.toUpperCase()}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    j.duration,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
                    },
                  ),
      ),
    );
  }
}