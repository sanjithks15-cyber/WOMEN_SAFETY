import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class AlertSettingsScreen extends StatefulWidget {
  const AlertSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AlertSettingsScreen> createState() => _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends State<AlertSettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notifyGuardians = true;
  bool _notifyPolice = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alert Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  const Text('Device Feedback', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text(
                    'Configure how your phone reacts when an SOS is triggered.',
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Play Loud Siren'),
                    activeColor: AppColors.primary,
                    value: _soundEnabled,
                    onChanged: (val) {
                      setState(() => _soundEnabled = val);
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Haptic Vibration'),
                    activeColor: AppColors.primary,
                    value: _vibrationEnabled,
                    onChanged: (val) {
                      setState(() => _vibrationEnabled = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SOS Recipients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text(
                    'Who gets notified immediately when you trigger an alert.',
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notify Trusted Guardians'),
                    activeColor: AppColors.primary,
                    value: _notifyGuardians,
                    onChanged: (val) {
                      setState(() => _notifyGuardians = val);
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Auto-Dial Police (112)'),
                    subtitle: const Text('Only enable if necessary', style: TextStyle(color: AppColors.destructive)),
                    activeColor: AppColors.destructive,
                    value: _notifyPolice,
                    onChanged: (val) {
                      setState(() => _notifyPolice = val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
