import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../providers/reward_provider.dart';

class PartnerBusinessesScreen extends StatelessWidget {
  const PartnerBusinessesScreen({super.key});

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
          context.tr('Partners'),
          style: GoogleFonts.outfit(
            color: darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: rewardProvider.isLoading && rewardProvider.partnerBusinesses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Text(
                  context.tr('Where to use your rewards:'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: rewardProvider.partnerBusinesses.isEmpty
                      ? Center(child: Text(context.tr('No partner businesses available yet.')))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: rewardProvider.partnerBusinesses.length,
                          itemBuilder: (context, index) => _buildBusinessCard(
                            context,
                            rewardProvider.partnerBusinesses[index].name,
                            rewardProvider.partnerBusinesses[index].rewards,
                            rewardProvider.partnerBusinesses[index].location,
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildBusinessCard(BuildContext context, String name, String rewards, String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: darkGreen.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 5),
          Text(context.loc.rewardsLabel(context.tr(rewards)), style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
