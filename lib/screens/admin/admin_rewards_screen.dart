import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/reward_item.dart';
import '../../services/api/api_exception.dart';
import '../../services/api/api_payload_utils.dart';
import '../../services/api/reward_api_service.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/admin_access_guard.dart';

class AdminRewardsScreen extends StatefulWidget {
  const AdminRewardsScreen({super.key});

  @override
  State<AdminRewardsScreen> createState() => _AdminRewardsScreenState();
}

class _AdminRewardsScreenState extends State<AdminRewardsScreen> {
  static const darkGreen = Color(0xFF1B5E20);

  final List<RewardItem> _rewards = [];
  bool _isLoading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ensureAdminAccess(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRewards());
  }

  Future<void> _loadRewards() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final payload =
          await context.read<RewardApiService>().fetchAdminRewards();
      final items =
          firstNestedList(payload, const [
            'rewards',
            'items',
            'data',
          ]).map(RewardItem.fromApi).toList();
      if (!mounted) return;
      setState(() {
        _rewards
          ..clear()
          ..addAll(items);
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load rewards.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showRewardForm([RewardItem? reward]) async {
    final title = TextEditingController(text: reward?.title);
    final description = TextEditingController(text: reward?.description);
    final points = TextEditingController(text: reward?.cost.toString());
    final emoji = TextEditingController(text: reward?.emoji);
    final partner = TextEditingController(text: reward?.partnerName);
    var saving = false;

    await showDialog<void>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(reward == null ? 'Add Reward' : 'Edit Reward'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _field(title, 'Reward name', Icons.card_giftcard),
                        const SizedBox(height: 12),
                        _field(description, 'Description', Icons.description),
                        const SizedBox(height: 12),
                        _field(
                          points,
                          'Points cost',
                          Icons.stars,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        _field(emoji, 'Emoji or icon', Icons.emoji_emotions),
                        const SizedBox(height: 12),
                        _field(partner, 'Partner business', Icons.store),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          saving ? null : () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed:
                          saving
                              ? null
                              : () async {
                                final cost = int.tryParse(points.text.trim());
                                if (title.text.trim().isEmpty ||
                                    cost == null ||
                                    cost < 0) {
                                  showAppSnackBar(
                                    this.context,
                                    'Enter a reward name and a valid points cost.',
                                    backgroundColor: Colors.red.shade700,
                                  );
                                  return;
                                }

                                setDialogState(() => saving = true);
                                try {
                                  final service =
                                      this.context.read<RewardApiService>();
                                  if (reward == null) {
                                    await service.createReward(
                                      title: title.text.trim(),
                                      description: description.text.trim(),
                                      pointsCost: cost,
                                      emoji: emoji.text.trim(),
                                      partnerName: partner.text.trim(),
                                    );
                                  } else {
                                    await service.updateReward(
                                      rewardPublicId: reward.id,
                                      title: title.text.trim(),
                                      description: description.text.trim(),
                                      pointsCost: cost,
                                      emoji: emoji.text.trim(),
                                      partnerName: partner.text.trim(),
                                    );
                                  }
                                  if (!dialogContext.mounted) return;
                                  Navigator.pop(dialogContext);
                                  await _loadRewards();
                                } on ApiException catch (error) {
                                  if (!mounted) return;
                                  showAppSnackBar(
                                    this.context,
                                    error.message,
                                    backgroundColor: Colors.red.shade700,
                                  );
                                  setDialogState(() => saving = false);
                                }
                              },
                      child:
                          saving
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(reward == null ? 'Add' : 'Save'),
                    ),
                  ],
                ),
          ),
    );

    title.dispose();
    description.dispose();
    points.dispose();
    emoji.dispose();
    partner.dispose();
  }

  Future<void> _removeReward(RewardItem reward) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove reward?'),
            content: Text(
              '${reward.title} will no longer appear in the rewards catalog. Existing redemptions will be kept.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await context.read<RewardApiService>().deleteReward(reward.id);
      await _loadRewards();
    } on ApiException catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        error.message,
        backgroundColor: Colors.red.shade700,
      );
    }
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: darkGreen),
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Points & Rewards Management'),
        actions: [
          IconButton(onPressed: _loadRewards, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : () => _showRewardForm(),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Reward'),
      ),
      body:
          _isLoading && _rewards.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _error != null && _rewards.isEmpty
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loadRewards,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadRewards,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: _rewards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final reward = _rewards[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              reward.isActive
                                  ? Colors.green.shade100
                                  : Colors.grey.shade300,
                          child: Text(
                            reward.emoji.isEmpty ? 'R' : reward.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        title: Text(
                          reward.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: reward.isActive ? null : Colors.grey,
                          ),
                        ),
                        subtitle: Text(
                          '${reward.cost} points'
                          '${reward.partnerName.isEmpty ? '' : ' • ${reward.partnerName}'}'
                          '${reward.isActive ? '' : ' • Removed'}',
                        ),
                        trailing:
                            reward.isActive
                                ? PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showRewardForm(reward);
                                    } else {
                                      _removeReward(reward);
                                    }
                                  },
                                  itemBuilder:
                                      (_) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        PopupMenuItem(
                                          value: 'remove',
                                          child: Text('Remove'),
                                        ),
                                      ],
                                )
                                : IconButton(
                                  tooltip: 'Edit and restore',
                                  onPressed: () => _showRewardForm(reward),
                                  icon: const Icon(Icons.restore),
                                ),
                        onTap: () => _showRewardForm(reward),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
