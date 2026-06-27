import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class SafetySetupScreen extends StatefulWidget {
  const SafetySetupScreen({Key? key}) : super(key: key);

  @override
  State<SafetySetupScreen> createState() => _SafetySetupScreenState();
}

class _SafetySetupScreenState extends State<SafetySetupScreen> {
  bool _useHardwareButtons = false;
  bool _requirePinToCancel = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Safety Setup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  const Text('Hardware Triggers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text(
                    'Trigger SOS by pressing the volume buttons rapidly without opening the app.',
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable Hardware SOS'),
                    activeColor: AppColors.primary,
                    value: _useHardwareButtons,
                    onChanged: (val) {
                      setState(() {
                        _useHardwareButtons = val;
                      });
                      if (val) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hardware triggers enabled (simulated)')),
                        );
                      }
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
                  const Text('Cancellation Security', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text(
                    'Require your 4-digit PIN to cancel an active SOS or Journey.',
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Require PIN to Cancel'),
                    activeColor: AppColors.primary,
                    value: _requirePinToCancel,
                    onChanged: (val) {
                      setState(() {
                        _requirePinToCancel = val;
                      });
                    },
                  ),
                  if (_requirePinToCancel)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: GradientButton(
                        text: 'Change PIN',
                        onPressed: () {
                          // Change pin logic
                        },
                      ),
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
