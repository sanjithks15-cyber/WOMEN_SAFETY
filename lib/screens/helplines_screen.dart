import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../models/app_models.dart';
import '../data/mock_data.dart';

class HelplinesScreen extends StatelessWidget {
  const HelplinesScreen({Key? key}) : super(key: key);

  void _callHelpline(BuildContext context, Helpline helpline) async {
    final Uri url = Uri.parse('tel:${helpline.number}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot call ${helpline.number}')),
        );
      }
    }
  }

  void _copyNumber(BuildContext context, Helpline helpline) {
    Clipboard.setData(ClipboardData(text: helpline.number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied ${helpline.number} to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final helplines = MockData.mockHelplines;

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
          'Emergency Helplines',
          style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: helplines.length,
          itemBuilder: (context, index) {
            final h = helplines[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: SoftCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone_in_talk_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            h.number,
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            h.description,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Colors.grey),
                      onPressed: () => _copyNumber(context, h),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone_enabled_rounded, color: AppColors.success),
                      onPressed: () => _callHelpline(context, h),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (index * 80).ms).slideY(begin: 0.1, end: 0);
          },
        ),
      ),
    );
  }
}