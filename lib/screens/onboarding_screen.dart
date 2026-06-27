import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/guardian_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/app_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  bool _isLoading = false;

  void _completeSetup() async {
    final name = _nameController.text.trim();
    final pin = _pinController.text.trim();
    
    if (name.isEmpty || pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name and a 6-digit PIN.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.registerNewUser(name, pin);

    if (success) {
      // Add guardian if provided
      final gName = _guardianNameController.text.trim();
      final gPhone = _guardianPhoneController.text.trim();
      
      if (gName.isNotEmpty && gPhone.isNotEmpty) {
        final guardianProvider = context.read<GuardianProvider>();
        await guardianProvider.addGuardian(gName, 'Friend', gPhone);
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AppShell(),
            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage)),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome to SafeHer',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              const Text(
                'Let\'s set up your profile and safety contacts before you start.',
                style: TextStyle(color: AppColors.mutedForeground, fontSize: 15),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 32),
              
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'Security PIN (6 digits)',
                        helperText: 'Used to cancel accidental SOS alerts.',
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 24),
              
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Primary Guardian (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _guardianNameController,
                      decoration: const InputDecoration(labelText: 'Guardian Name'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _guardianPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Guardian Phone Number'),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 40),
              
              GradientButton(
                text: 'Complete Setup',
                isLoading: _isLoading,
                onPressed: _completeSetup,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
