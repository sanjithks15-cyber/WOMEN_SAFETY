import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/app_models.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  void _markAllAsRead() async {
    await context.read<NotificationProvider>().markAllAsRead();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All notifications marked as read'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _toggleRead(String id) {
    context.read<NotificationProvider>().toggleRead(id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final List<AppNotification> notifications = provider.notifications
        .map((n) => AppNotification.fromMap(n as Map<String, dynamic>))
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
          'Notifications',
          style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read_rounded, color: AppColors.primary),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
                ? const Center(
                    child: Text(
                      'No notifications yet.',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
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
                        case 'journey':
                        default:
                          typeColor = AppColors.secondary;
                          typeIcon = Icons.directions_run_rounded;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _toggleRead(n.id),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: n.isRead ? AppColors.border : AppColors.primary.withOpacity(0.3),
                                width: n.isRead ? 1 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: n.isRead ? Colors.black.withOpacity(0.01) : AppColors.primary.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: typeColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(typeIcon, color: typeColor, size: 22),
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
                                              n.title,
                                              style: TextStyle(
                                                fontWeight: n.isRead ? FontWeight.w600 : FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          if (!n.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.message,
                                        style: TextStyle(
                                          color: n.isRead ? Colors.grey.shade600 : Colors.black87,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        n.time,
                                        style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 80).ms).slideY(begin: 0.1, end: 0);
                    },
                  ),
      ),
    );
  }
}