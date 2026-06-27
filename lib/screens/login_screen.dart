import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  void _sendOTP() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid phone number'),
          backgroundColor: AppColors.destructive,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final formattedNumber =
        phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';

    await context.read<AuthProvider>().sendOTP(
      formattedNumber,
      () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OTPScreen()),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, Color(0xFFFCE4EC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: AppColors.primary,
                        size: 48,
                      ),
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome to SafeHer',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your phone number to proceed with verification',
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 15,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 32),
                  SoftCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: '+91 98765 43210',
                            prefixIcon: Icon(Icons.phone_rounded, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 24),
                        GradientButton(
                          text: 'Send Verification Code',
                          isLoading: authProvider.isLoading,
                          onPressed: _sendOTP,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}