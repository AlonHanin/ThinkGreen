import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n_app_localizations.dart';
import '../../utils/app_feedback.dart';

class SyncAppsScreen extends StatelessWidget {
  const SyncAppsScreen({super.key});

  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreenBg = Color(0xFFE8F5E9);

  void _showComingSoon(BuildContext context) {
    showAppSnackBar(context, context.tr('Integration disabled for now (Coming Soon)'));
  }

  @override
  Widget build(BuildContext context) {
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
          context.tr('Sync Services'),
          style: GoogleFonts.outfit(
            color: darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              context.tr('Automate Your\nPoints'),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: darkGreen,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              context.tr('Connect your favorite apps to track eco-actions automatically.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkGreen.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            _buildSyncCard(context, 'STRAVA', context.tr('Track Runs, Walks And Bike Rides'), Icons.directions_run),
            const SizedBox(height: 20),
            _buildSyncCard(context, 'MOOVIT', context.tr('Track Your Public Transport Trips'), Icons.directions_bus),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncCard(BuildContext context, String title, String subtitle, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkGreen.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: darkGreen, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkGreen),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: darkGreen.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => _showComingSoon(context),
              style: TextButton.styleFrom(
                backgroundColor: darkGreen.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                context.tr('CONNECT'),
                style: const TextStyle(color: darkGreen, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
