import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';
import 'safety_setup_screen.dart';
import 'alert_settings_screen.dart';
import 'support_faq_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _signOut(BuildContext context) async {
    await context.read<AuthProvider>().signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.backendUser;
    
    final name = user?['name'] ?? 'User';
    final phone = user?['phone'] ?? authProvider.phoneNumber;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              GradientCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white24,
                      child: Text(
                        initial,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SoftCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.shield_rounded,
                      title: 'Safety Setup',
                      subtitle: 'Manage PIN & trigger settings',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SafetySetupScreen()));
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: Icons.notifications_active_rounded,
                      title: 'Alert Settings',
                      subtitle: 'Sound, vibration & notify rules',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertSettingsScreen()));
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Support & FAQs',
                      subtitle: 'Contact us or get help using SafeHer',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportFAQScreen()));
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _signOut(context),
                icon: const Icon(Icons.logout_rounded, color: AppColors.destructive),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.destructive),
                  foregroundColor: AppColors.destructive,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
      onTap: onTap,
    );
  }
}