import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../providers/reward_provider.dart';
import '../../utils/app_feedback.dart';
import 'active_rewards.dart';
import 'available_reward.dart';
import 'partner_businesses.dart';

class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  static const Color darkGreen = Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    final rewardProvider = context.watch<RewardProvider>();

    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: rewardProvider.isLoading && rewardProvider.catalog.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  context.tr('Use your points to get rewards and benefits'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: darkGreen.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 25),
                _buildPointsCard(context, rewardProvider.availablePoints),
                const SizedBox(height: 30),
                _buildProgressSection(context, rewardProvider),
                const SizedBox(height: 30),
                _buildNavigationCard(
                  context,
                  context.tr('What can you do with your points?'),
                  context.tr('View Available Rewards'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AvailableRewardsScreen()),
                  ),
                ),
                _buildNavigationCard(
                  context,
                  context.tr('See where rewards can be used'),
                  context.tr('Partner Businesses'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PartnerBusinessesScreen()),
                  ),
                ),
                _buildNavigationCard(
                  context,
                  context.tr('Rewards you redeemed but have not used yet'),
                  context.tr('My Active Rewards'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ActiveRewardsScreen()),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.outfit(color: darkGreen, fontSize: 28, height: 1.1),
              children: [
                TextSpan(
                  text: '${context.tr('Redeem')}\n',
                  style: const TextStyle(fontWeight: FontWeight.w300),
                ),
                TextSpan(
                  text: context.tr('Points'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: darkGreen),
            onPressed: () => showComingSoonSnackBar(context, feature: 'Notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context, int availablePoints) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            context.tr('Your Available Points:'),
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            decoration: BoxDecoration(
              color: darkGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              availablePoints.toString(),
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: darkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, RewardProvider rewardProvider) {
    return Column(
      children: [
        Text(
          context.isRtl ? 'אתה מתקרב לפרס הבא שלך!' : "You're getting closer to your next reward!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: darkGreen.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: rewardProvider.progressToNextReward,
            child: Container(
              decoration: BoxDecoration(
                color: darkGreen,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          rewardProvider.nextRewardThreshold == 0
              ? context.tr('All rewards are unlocked.')
              : context.loc.nextRewardAt(rewardProvider.nextRewardThreshold),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: darkGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCard(BuildContext context, String title, String buttonText, {required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 5, bottom: 5),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: darkGreen.withValues(alpha: 0.6),
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: darkGreen.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  buttonText,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: darkGreen,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 18, color: darkGreen),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
