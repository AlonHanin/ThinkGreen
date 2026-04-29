import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../main_navigation_screen.dart';
import '../../providers/activity_provider.dart';
import '../../providers/reward_provider.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_feedback.dart';
import '../activities/manual_report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkGreen = Color(0xFF1B5E20);
    const Color lightGreenText = Color(0xFF66BB6A);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryText = isDark ? const Color(0xFF8FE3A2) : darkGreen;
    final secondaryText =
        isDark ? Colors.white.withValues(alpha: 0.72) : lightGreenText;
    final trackColor =
        isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white;
    final actionColor = isDark ? const Color(0xFF2F7D3C) : darkGreen;

    final activityProvider = context.watch<ActivityProvider>();
    final rewardProvider = context.watch<RewardProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final totalPoints = rewardProvider.availablePoints;
    final recentActivities = activityProvider.recentActivities(limit: 3);
    final displayName =
        sessionProvider.currentUser.firstName.trim().isNotEmpty
            ? sessionProvider.currentUser.firstName.trim()
            : context.tr('Unknown User');

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final useCompactGreeting = constraints.maxWidth < 240;
                      final greeting =
                          useCompactGreeting
                              ? context.loc.welcomeBackFirstName(displayName)
                              : context.loc.welcomeBackUser(displayName);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              color: primaryText,
                              fontSize: useCompactGreeting ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('Good Morning'),
                            style: TextStyle(color: secondaryText),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.notifications_none, color: primaryText),
                  onPressed:
                      () => showComingSoonSnackBar(
                        context,
                        feature: 'Notifications',
                      ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Text(
                    context.tr('Your Points'),
                    style: GoogleFonts.outfit(color: primaryText, fontSize: 18),
                  ),
                  Text(
                    totalPoints.toString(),
                    style: GoogleFonts.outfit(
                      color: primaryText,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: (totalPoints / 500).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryText,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              context.tr('Quick Actions'),
              style: GoogleFonts.outfit(
                color: primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildQuickAction(
                  context,
                  context.tr('Report Green\nActivity'),
                  Icons.add_circle_outline,
                  actionColor,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManualReportScreen(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildQuickAction(
                  context,
                  context.tr('Redeem\nPoints'),
                  Icons.card_giftcard,
                  actionColor,
                  () => MainNavigationScreen.maybeOf(context)?.updateIndex(2),
                ),
                const SizedBox(width: 12),
                _buildQuickAction(
                  context,
                  context.tr('Explore\nChallenges'),
                  Icons.explore_outlined,
                  actionColor,
                  () => MainNavigationScreen.maybeOf(context)?.updateIndex(3),
                ),
              ],
            ),
            const SizedBox(height: 35),
            _buildSectionHeader(primaryText, context.tr('Recent Activity')),
            const SizedBox(height: 12),
            if (recentActivities.isEmpty)
              Text(
                context.tr(
                  'No activities yet. Submit your first green action to start earning points.',
                ),
                style: TextStyle(
                  color:
                      isDark
                          ? Colors.white.withValues(alpha: 0.68)
                          : darkGreen.withValues(alpha: 0.7),
                ),
              )
            else
              ...recentActivities.map(
                (activity) => _buildActivityItem(
                  context,
                  primaryText,
                  context.tr(activity.title),
                  context.tr(
                    activity.status.name[0].toUpperCase() +
                        activity.status.name.substring(1),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(Color color, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: color,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    Color color,
    String title,
    String status,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
