import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../models/crime_zone_model.dart';
import '../../providers/safety_provider.dart';

class CrimeZonesScreen extends StatefulWidget {
  const CrimeZonesScreen({Key? key}) : super(key: key);

  @override
  State<CrimeZonesScreen> createState() => _CrimeZonesScreenState();
}

class _CrimeZonesScreenState extends State<CrimeZonesScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SafetyProvider>().fetchCrimeZones();
    });
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return AppColors.destructive;
      case 'medium':
        return AppColors.warning;
      case 'low':
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SafetyProvider>();
    final List<CrimeZone> allZones = provider.crimeZones
        .map((z) => CrimeZone.fromMap(z as Map<String, dynamic>))
        .toList();

    final List<CrimeZone> filteredZones = _selectedFilter == 'all'
        ? allZones
        : allZones.where((z) => z.riskLevel.toLowerCase() == _selectedFilter).toList();

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
          'Crime Heat Zones',
          style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFilterChip('All', 'all'),
                  _buildFilterChip('High', 'high'),
                  _buildFilterChip('Medium', 'medium'),
                  _buildFilterChip('Low', 'low'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredZones.isEmpty
                      ? const Center(
                          child: Text(
                            'No zones found for selected filter.',
                            style: TextStyle(color: AppColors.mutedForeground),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: filteredZones.length,
                          itemBuilder: (context, index) {
                            final zone = filteredZones[index];
                            final riskColor = _getRiskColor(zone.riskLevel);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: SoftCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            zone.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: riskColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: riskColor.withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            zone.riskLevel.toUpperCase(),
                                            style: TextStyle(
                                              color: riskColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      zone.description,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                    ),
                                    const Divider(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Reports: ${zone.reportsCount}',
                                          style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                                        ),
                                        Text(
                                          'Last Incident: ${zone.lastIncident.isNotEmpty ? zone.lastIncident : "No recent reports"}',
                                          style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
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
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.foreground,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}