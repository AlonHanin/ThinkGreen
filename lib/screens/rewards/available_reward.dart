import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../providers/reward_provider.dart';
import '../../utils/app_feedback.dart';

class AvailableRewardsScreen extends StatelessWidget {
  const AvailableRewardsScreen({super.key});

  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreenBg = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    final rewardProvider = context.watch<RewardProvider>();

    return Scaffold(
      backgroundColor: lightGreenBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('Available Rewards'),
          style: GoogleFonts.outfit(
            color: darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              context.tr('Choose a reward and redeem your points:'),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: darkGreen.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.loc.availablePointsLabel(rewardProvider.availablePoints),
            style: const TextStyle(fontWeight: FontWeight.w700, color: darkGreen),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: rewardProvider.isLoading && rewardProvider.catalog.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    physics: const BouncingScrollPhysics(),
                    itemCount: rewardProvider.catalog.length,
                    itemBuilder: (context, index) {
                      final reward = rewardProvider.catalog[index];
                      final canRedeem = rewardProvider.availablePoints >= reward.cost;

                      return _buildRewardCard(
                        context,
                        title: reward.title,
                        cost: reward.cost,
                        emoji: reward.emoji,
                        partnerName: reward.partnerName,
                        canRedeem: canRedeem,
                        isRedeeming: rewardProvider.isRedeeming,
                        onRedeem: () async {
                          final error = await context.read<RewardProvider>().redeemReward(reward);

                          if (!context.mounted) return;

                          if (error != null) {
                            showAppSnackBar(
                              context,
                              context.tr(error),
                              backgroundColor: Colors.red.shade700,
                            );
                            return;
                          }

                          showAppSnackBar(
                            context,
                            context.isRtl ? '${context.tr(reward.title)} מומש בהצלחה.' : '${reward.title} redeemed successfully.',
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(
    BuildContext context, {
    required String title,
    required int cost,
    required String emoji,
    required String partnerName,
    required bool canRedeem,
    required bool isRedeeming,
    required Future<void> Function() onRedeem,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkGreen.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: lightGreenBg,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(title),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.loc.pointsLabel(cost),
                  style: TextStyle(
                    color: darkGreen.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(partnerName, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canRedeem && !isRedeeming ? () => onRedeem() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: darkGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(70, 34),
            ),
            child: isRedeeming
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                  )
                : Text(
                    canRedeem ? context.tr('Redeem') : context.tr('Locked'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
