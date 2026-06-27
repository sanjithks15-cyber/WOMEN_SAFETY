import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class SupportFAQScreen extends StatelessWidget {
  const SupportFAQScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Support & FAQs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contact Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text(
                    'Having trouble with the app or need urgent help?',
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.email_rounded, color: AppColors.primary),
                    title: const Text('Email Us'),
                    subtitle: const Text('support@safeher.app'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.phone_rounded, color: AppColors.primary),
                    title: const Text('Call Helpline'),
                    subtitle: const Text('1800-SAFE-HER'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Frequently Asked Questions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            const SizedBox(height: 12),
            _buildFAQItem('How do I add a Guardian?', 'Go to the Guardians tab and click the + icon in the top right. You can enter their name and phone number. They will receive an SMS invite.'),
            _buildFAQItem('What happens when I trigger SOS?', 'The app will immediately vibrate, sound an alarm (if enabled), and send your live location to all your trusted guardians.'),
            _buildFAQItem('Is my location always tracked?', 'No, SafeHer only tracks your location when you explicitly start a Journey or trigger an SOS alert. Your privacy is important to us.'),
            _buildFAQItem('How does Safe Routing work?', 'We use historical road report data and crime zone density to suggest paths that have high street light visibility, police presence, and crowds.'),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer, style: const TextStyle(color: AppColors.mutedForeground, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
