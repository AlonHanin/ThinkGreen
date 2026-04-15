import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../l10n_app_localizations.dart';
import '../../models/reward_item.dart';
import '../../providers/reward_provider.dart';

class QRCodeScreen extends StatelessWidget {
  final RewardRedemption redemption;

  const QRCodeScreen({super.key, required this.redemption});

  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreenBg = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    final rewardProvider = context.read<RewardProvider>();
    final payload = rewardProvider.qrPayloadFor(redemption);

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
          context.tr('Redeem Reward'),
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
          const SizedBox(height: 30),
          Text(
            context.tr(redemption.reward.title),
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: darkGreen,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.loc.showQrAt(redemption.reward.partnerName),
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: darkGreen,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: QrImageView(
              data: payload,
              version: QrVersions.auto,
              size: 180,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: darkGreen,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: darkGreen,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.loc.codeLabel(redemption.redemptionCode),
            style: const TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Text(
              context.tr('Keep this screen open until the business scans your code. Enjoy your reward!'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkGreen.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
