import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../models/app_models.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import 'guardians/guardians_screen.dart';
import 'road_safety/road_safety_screen.dart';
import 'crime/crime_zones_screen.dart';
import 'safe_places/safe_places_screen.dart';
import 'helplines_screen.dart';
import 'journey/journey_history_screen.dart';
import 'journey/journey_screen.dart';
import 'sos/sos_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              _buildTopBar(context),
              const SizedBox(height: 16),

              // Safety Score Hero Card
              _buildSafetyCard(context).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Start Journey + SOS
              _buildActionButtons(context).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Quick Actions Grid
              _buildQuickActions(context).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),

              // Recent Alerts
              _buildSectionHeader(
                context,
                title: 'Recent Alerts',
                actionText: 'View all',
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
              ),
              const SizedBox(height: 10),
              _buildRecentAlerts(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.backendUser?['name'] ?? 'User';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good Evening',
              style: TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 14,
              ),
            ),
            Text(
              'Hey, $userName 👋',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                const Icon(Icons.notifications_rounded, color: AppColors.foreground),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyCard(BuildContext context) {
    return GradientCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Safety Score',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      '82',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'SECURE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bengaluru, IN',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SoftCard(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JourneyScreen()),
            ),
            child: const Column(
              children: [
                Icon(Icons.directions_run_rounded, color: AppColors.primary, size: 32),
                SizedBox(height: 8),
                Text(
                  'Start Journey',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SoftCard(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SOSScreen()),
            ),
            child: const Column(
              children: [
                Icon(Icons.emergency_rounded, color: AppColors.destructive, size: 32),
                SizedBox(height: 8),
                Text(
                  'SOS Active',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        'title': 'Guardians',
        'icon': Icons.people_rounded,
        'color': const Color(0xFFEC4899),
        'screen': const GuardiansScreen()
      },
      {
        'title': 'Road Safety',
        'icon': Icons.alt_route_rounded,
        'color': const Color(0xFF8B5CF6),
        'screen': const RoadSafetyScreen()
      },
      {
        'title': 'Crime Zones',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFF59E0B),
        'screen': const CrimeZonesScreen()
      },
      {
        'title': 'Safe Places',
        'icon': Icons.local_hospital_rounded,
        'color': const Color(0xFF10B981),
        'screen': const SafePlacesScreen()
      },
      {
        'title': 'Helplines',
        'icon': Icons.phone_in_talk_rounded,
        'color': const Color(0xFFEF4444),
        'screen': const HelplinesScreen()
      },
      {
        'title': 'History',
        'icon': Icons.history_rounded,
        'color': const Color(0xFF3B82F6),
        'screen': const JourneyHistoryScreen()
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return SoftCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => action['screen'] as Widget),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['title'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.foreground,
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAlerts(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final alerts = provider.notifications
        .take(2)
        .map((n) => AppNotification.fromMap(n as Map<String, dynamic>))
        .toList();

    if (alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        alignment: Alignment.center,
        child: const Text(
          'No recent alerts.',
          style: TextStyle(color: AppColors.mutedForeground),
        ),
      );
    }

    return Column(
      children: alerts.map((n) {
        Color typeColor;
        IconData typeIcon;
        switch (n.type.toLowerCase()) {
          case 'sos':
            typeColor = AppColors.destructive;
            typeIcon = Icons.emergency_rounded;
            break;
          case 'crime':
            typeColor = AppColors.warning;
            typeIcon = Icons.warning_rounded;
            break;
          case 'guardian':
            typeColor = AppColors.primary;
            typeIcon = Icons.people_rounded;
            break;
          default:
            typeColor = AppColors.secondary;
            typeIcon = Icons.directions_run_rounded;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(typeIcon, color: typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          n.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          n.time,
                          style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.message,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}