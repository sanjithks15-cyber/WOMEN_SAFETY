import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../models/app_models.dart';
import '../../providers/safety_provider.dart';

class RoadReportsScreen extends StatefulWidget {
  const RoadReportsScreen({Key? key}) : super(key: key);

  @override
  State<RoadReportsScreen> createState() => _RoadReportsScreenState();
}

class _RoadReportsScreenState extends State<RoadReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SafetyProvider>().fetchRoadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SafetyProvider>();
    final List<RoadReport> reports = provider.roadReports
        .map((r) => RoadReport.fromMap(r as Map<String, dynamic>))
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
          'Community Road Reports',
          style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : reports.isEmpty
                ? const Center(
                    child: Text(
                      'No reports submitted yet.',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final r = reports[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: SoftCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      r.roadName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        r.rating.toString(),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Reported by ${r.reporter} • ${r.time}',
                                style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11),
                              ),
                              const SizedBox(height: 12),
                              if (r.comment.isNotEmpty) ...[
                                Text(
                                  r.comment,
                                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                                ),
                                const SizedBox(height: 12),
                              ],
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: r.tags.map((tag) {
                                  final isNegative = tag.contains('Poor') || tag.contains('Isolated');
                                  final tagColor = isNegative ? AppColors.destructive : AppColors.success;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: tagColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        color: tagColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
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