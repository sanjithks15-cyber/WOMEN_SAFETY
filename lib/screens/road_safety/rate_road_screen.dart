import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/safety_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/geocoding_service.dart';

class RateRoadScreen extends StatefulWidget {
  const RateRoadScreen({Key? key}) : super(key: key);

  @override
  State<RateRoadScreen> createState() => _RateRoadScreenState();
}

class _RateRoadScreenState extends State<RateRoadScreen> {
  final _roadController = TextEditingController();
  final _commentController = TextEditingController();
  final _roadFocusNode = FocusNode();
  double _rating = 0.0;
  final List<String> _selectedTags = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _roadController.dispose();
    _commentController.dispose();
    _roadFocusNode.dispose();
    super.dispose();
  }

  final List<String> _availableTags = [
    'Well Lit',
    'Poor Lighting',
    'Isolated',
    'Busy Street',
    'CCTV Active',
    'Security Guards',
    'Potholes',
    'Sidewalks Present'
  ];

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _submitRating() async {
    final road = _roadController.text.trim();
    if (road.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the road name')),
      );
      return;
    }
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final safetyProvider = context.read<SafetyProvider>();
    final authProvider = context.read<AuthProvider>();
    final reporterName = authProvider.backendUser?['name'] ?? 'Anonymous';

    final success = await safetyProvider.createRoadReport(
      road,
      reporterName,
      _rating,
      List.from(_selectedTags),
      _commentController.text.trim(),
    );

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Road audit submitted successfully. Thank you!' : 'Failed to submit road audit.'),
          backgroundColor: success ? AppColors.success : AppColors.destructive,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Rate Road Safety',
          style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Road / Street Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Autocomplete<String>(
                      textEditingController: _roadController,
                      focusNode: _roadFocusNode,
                      optionsBuilder: (TextEditingValue textEditingValue) async {
                        if (textEditingValue.text.length < 3) {
                          return const Iterable<String>.empty();
                        }
                        return await GeocodingService.getSuggestions(textEditingValue.text);
                      },
                      onSelected: (String selection) {
                        _roadController.text = selection;
                      },
                      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onFieldSubmitted: (value) => onFieldSubmitted(),
                          decoration: const InputDecoration(
                            hintText: 'e.g. 100 Feet Road, Indiranagar',
                            prefixIcon: Icon(Icons.edit_road_rounded, color: AppColors.primary),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return _buildAutocompleteDropdown(context, onSelected, options);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Overall Safety Rating', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: AppColors.warning,
                            size: 40,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1.0;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    const Text('Select Road Features', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return GestureDetector(
                          onTap: () => _toggleTag(tag),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.secondary.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.secondary : AppColors.border,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: isSelected ? AppColors.secondary : AppColors.foreground,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('Additional Comments', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Add description, landmarks or details...',
                      ),
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      text: 'Submit Audit',
                      isLoading: _isSubmitting,
                      onPressed: _submitRating,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutocompleteDropdown(
    BuildContext context,
    AutocompleteOnSelected<String> onSelected,
    Iterable<String> options,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width - 64, // Matches input card width with margins
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (BuildContext context, int index) {
                final String option = options.elementAt(index);
                return ListTile(
                  dense: true,
                  title: Text(
                    option,
                    style: const TextStyle(fontSize: 13, color: AppColors.foreground),
                  ),
                  leading: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                  onTap: () => onSelected(option),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}