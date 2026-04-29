import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n_app_localizations.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/action_button_widget.dart';
import 'activity_history_screen.dart';
import 'manual_report_screen.dart';
import 'sync_apps_screen.dart';

class ActivitiesMenuScreen extends StatelessWidget {
  const ActivitiesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkGreen = Color(0xFF1B5E20);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF8FE3A2) : darkGreen;
    final secondaryColor =
        isDark
            ? Colors.white.withValues(alpha: 0.68)
            : darkGreen.withValues(alpha: 0.7);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: accentColor),
                onPressed:
                    () => showComingSoonSnackBar(
                      context,
                      feature: 'Notifications',
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                context.tr('Activities'),
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('Manage, report and sync\nall your green actions'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: secondaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ActionButtonWidget(
          title: context.tr('Report Green Activities'),
          subtitle: context.tr(
            'Add your actions manually with photo verification',
          ),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManualReportScreen()),
              ),
        ),
        ActionButtonWidget(
          title: context.tr('Green Activity History'),
          subtitle: context.tr('See approved, pending and rejected reports'),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ActivityHistoryScreen(),
                ),
              ),
        ),
        ActionButtonWidget(
          title: context.tr('Sync External Apps'),
          subtitle: context.tr(
            'Prepare automatic tracking from services like STRAVA',
          ),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SyncAppsScreen()),
              ),
        ),
      ],
    );
  }
}
