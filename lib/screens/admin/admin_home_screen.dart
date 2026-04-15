import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../models/challenge.dart';
import '../../providers/activity_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/reward_provider.dart';
import '../../utils/app_feedback.dart';
import 'admin_approvals_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreenBg = Color(0xFFE8F5E9);

  final List<Map<String, dynamic>> _challengeTemplates = [
    {
      'title': 'Recycle Bottles',
      'points': 150,
      'target': 10,
      'icon': '♻️',
      'desc': 'Recycle plastic or glass bottles.',
      'keywords': ['recycled', 'bottle', 'plastic']
    },
    {
      'title': 'Public Transport',
      'points': 200,
      'target': 5,
      'icon': '🚌',
      'desc': 'Use public transport instead of a private car.',
      'keywords': ['public transport', 'bus', 'transport']
    },
    {
      'title': 'Bike Commute',
      'points': 350,
      'target': 3,
      'icon': '🚲',
      'desc': 'Bike to work or school.',
      'keywords': ['bike', 'biked', 'bicycle', 'walked']
    },
    {
      'title': 'Reusable Bottle',
      'points': 120,
      'target': 5,
      'icon': '🥤',
      'desc': 'Use a reusable bottle instead of disposable plastic.',
      'keywords': ['reusable', 'bottle', 'cup']
    },
  ];

  Map<String, dynamic>? _selectedTemplate;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _pointsController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _updateFieldsFromTemplate(Map<String, dynamic> template) {
    setState(() {
      _selectedTemplate = template;
      _nameController.text = template['title'].toString();
      _pointsController.text = template['points'].toString();
      _targetController.text = template['target'].toString();
    });
  }

  void _showStatisticsDialog(BuildContext context) {
    final activityProvider = context.read<ActivityProvider>();
    final challengeProvider = context.read<ChallengeProvider>();
    final rewardProvider = context.read<RewardProvider>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('System Statistics')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow(context.tr('Total activities'), activityProvider.activities.length.toString()),
            _buildStatRow(context.tr('Approved'), activityProvider.approvedActivities.length.toString()),
            _buildStatRow(context.tr('Pending'), activityProvider.pendingActivities.length.toString()),
            _buildStatRow(context.tr('Rejected'), activityProvider.rejectedActivities.length.toString()),
            _buildStatRow(context.tr('Active challenges'), challengeProvider.challenges.length.toString()),
            _buildStatRow(context.tr('Redeemed rewards'), rewardProvider.activeRedemptions.length.toString()),
            _buildStatRow(context.tr('Earned points'), rewardProvider.earnedPoints.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr('Close')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
                  backgroundColor: lightGreenBg,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.exit_to_app, color: darkGreen),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      context.tr('Admin Control'),
                      style: GoogleFonts.outfit(
                        color: darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildAdminCard(
                          context,
                          'Create New\nChallenge',
                          Icons.add_task,
                          () => _showCreateChallengeDialog(context),
                        ),
                        const SizedBox(height: 15),
                        _buildAdminCard(
                          context,
                          'System\nStatistics',
                          Icons.bar_chart,
                          () => _showStatisticsDialog(context),
                        ),
                        const SizedBox(height: 15),
                        _buildAdminCard(
                          context,
                          'Review\nRequests',
                          Icons.fact_check,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminApprovalsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: darkGreen),
            const SizedBox(width: 20),
            Text(
              context.tr(title),
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateChallengeDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('Publish New Challenge'),
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<Map<String, dynamic>>(
                  decoration: InputDecoration(
                    labelText: context.tr('Choose from templates'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: _challengeTemplates
                      .map(
                        (template) => DropdownMenuItem(
                          value: template,
                          child: Text(
                            '${template['icon']} ${template['title']}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    _updateFieldsFromTemplate(value);
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField('Challenge Name', Icons.edit, _nameController),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Points',
                        Icons.stars,
                        _pointsController,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        'Target',
                        Icons.repeat,
                        _targetController,
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setModalState(() => _selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ends on: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_month, color: darkGreen),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      if (_nameController.text.trim().isEmpty) {
                        showAppSnackBar(
                          context,
                          context.tr('Please enter a challenge name.'),
                          backgroundColor: Colors.red.shade700,
                        );
                        return;
                      }

                      final newChallenge = Challenge(
                        id: DateTime.now().toString(),
                        title: _nameController.text.trim(),
                        description: _selectedTemplate?['desc']?.toString() ??
                            'Custom eco challenge.',
                        points: int.tryParse(_pointsController.text) ?? 0,
                        targetCount: int.tryParse(_targetController.text) ?? 1,
                        endDate: _selectedDate,
                        icon: _selectedTemplate?['icon']?.toString() ?? '🌱',
                        trackingKeywords: ((_selectedTemplate?['keywords'] as List?)
                                    ?.map((item) => item.toString())
                                    .toList()) ??
                            const [],
                        linkedActivityTitle: _selectedTemplate?['title']?.toString() == 'Public Transport'
                            ? 'Used Public Transport'
                            : _selectedTemplate?['title']?.toString() == 'Recycle Bottles'
                                ? 'Recycled Plastic Bottles'
                                : _selectedTemplate?['title']?.toString() == 'Reusable Bottle'
                                    ? 'Used A Reusable Bottle'
                                    : _selectedTemplate?['title']?.toString() == 'Bike Commute'
                                        ? 'Walked / Biked to Work'
                                        : _nameController.text.trim(),
                      );

                      final error = await context.read<ChallengeProvider>().addChallenge(newChallenge);
                      if (!context.mounted) return;
                      if (error != null) {
                        showAppSnackBar(
                          context,
                          context.tr(error),
                          backgroundColor: Colors.red.shade700,
                        );
                        return;
                      }
                      Navigator.pop(context);
                      showAppSnackBar(context, context.tr('Challenge published successfully.'));
                    },
                    child: const Text(
                      'PUBLISH NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: darkGreen),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
