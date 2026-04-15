import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../models/reward_item.dart';
import '../../providers/reward_provider.dart';
import 'qr_code.dart';

class ActiveRewardsScreen extends StatelessWidget {
  const ActiveRewardsScreen({super.key});

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
          context.tr('My Active Rewards'),
          style: GoogleFonts.outfit(
            color: darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: rewardProvider.isLoading && rewardProvider.activeRedemptions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : rewardProvider.activeRedemptions.isEmpty
              ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  context.tr('No active rewards yet. Redeem a reward first to generate a QR code.'),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    context.tr('Redeemed rewards ready to use:'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: rewardProvider.activeRedemptions.length,
                    itemBuilder: (context, index) {
                      return _buildActiveCard(context, rewardProvider.activeRedemptions[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActiveCard(BuildContext context, RewardRedemption reward) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(reward.reward.title),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.loc.redeemedPointsPartner(reward.reward.cost, reward.reward.partnerName),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  context.loc.redeemedOn(DateFormat('dd/MM/yyyy').format(reward.redeemedAt)),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QRCodeScreen(redemption: reward)),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.qr_code_2, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
