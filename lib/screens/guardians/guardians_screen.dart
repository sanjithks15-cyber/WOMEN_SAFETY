import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../models/guardian_model.dart';
import '../../providers/guardian_provider.dart';
import '../../providers/journey_provider.dart';
import '../guardian/guardian_tracking_screen.dart';

class GuardiansScreen extends StatefulWidget {
  const GuardiansScreen({Key? key}) : super(key: key);

  @override
  State<GuardiansScreen> createState() => _GuardiansScreenState();
}

class _GuardiansScreenState extends State<GuardiansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuardianProvider>().fetchGuardians();
    });
  }

  void _callGuardian(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot call $phone')),
        );
      }
    }
  }

  void _deleteGuardian(String id) async {
    final success = await context.read<GuardianProvider>().deleteGuardian(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Guardian removed' : 'Failed to remove guardian'),
          backgroundColor: success ? AppColors.success : AppColors.destructive,
        ),
      );
    }
  }

  void _showAddGuardianDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRelation = 'Friend';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add Trusted Guardian',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRelation,
                decoration: const InputDecoration(labelText: 'Relation'),
                items: ['Father', 'Mother', 'Sister', 'Brother', 'Friend', 'Partner', 'Other']
                    .map((relation) => DropdownMenuItem(
                          value: relation,
                          child: Text(relation),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setLocalState(() => selectedRelation = val);
                  }
                },
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Save Guardian',
                onPressed: () async {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  if (name.isNotEmpty && phone.isNotEmpty) {
                    Navigator.pop(ctx);
                    final success = await context.read<GuardianProvider>().addGuardian(name, selectedRelation, phone);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Guardian saved successfully!' : 'Failed to save guardian.'),
                          backgroundColor: success ? AppColors.success : AppColors.destructive,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GuardianProvider>();
    final List<Guardian> guardiansList = provider.guardians
        .map((g) => Guardian.fromMap(g as Map<String, dynamic>))
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
          'My Guardians',
          style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 28),
            onPressed: _showAddGuardianDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientCard(
                child: Row(
                  children: [
                    const Icon(Icons.people_alt_rounded, color: Colors.white, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Safety Circle',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'These contacts will be alerted immediately if you trigger SOS.',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : guardiansList.isEmpty
                        ? const Center(
                            child: Text(
                              'No guardians added yet.',
                              style: TextStyle(color: AppColors.mutedForeground),
                            ),
                          )
                        : ListView.builder(
                            itemCount: guardiansList.length,
                            itemBuilder: (context, index) {
                              final g = guardiansList[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: SoftCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppColors.primary.withOpacity(0.1),
                                        foregroundColor: AppColors.primary,
                                        child: Text(g.name.isNotEmpty ? g.name.substring(0, 1).toUpperCase() : 'G'),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              g.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${g.relation} • ${g.phone}',
                                              style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.phone_rounded, color: AppColors.success),
                                        onPressed: () => _callGuardian(g.phone),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                                        onPressed: () {
                                          final journeyProvider = context.read<JourneyProvider>();
                                          if (journeyProvider.activeJourney == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active journey to track right now!')));
                                            return;
                                          }
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => GuardianTrackingScreen(
                                            journeyId: journeyProvider.activeJourney!['id'],
                                            wardName: g.name,
                                          )));
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.destructive),
                                        onPressed: () => _deleteGuardian(g.id),
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
      ),
    );
  }
}