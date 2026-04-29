import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../models/challenge.dart';
import '../../providers/challenge_provider.dart';
import '../../utils/app_feedback.dart';
import '../activities/manual_report_screen.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreenBg = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: Consumer<ChallengeProvider>(
            builder: (context, challengeProvider, _) {
              if (challengeProvider.isLoading &&
                  challengeProvider.challenges.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (challengeProvider.challenges.isEmpty) {
                return Center(
                  child: Text(
                    context.tr('No challenges available yet.'),
                    style: TextStyle(color: textColor),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: challengeProvider.challenges.length,
                itemBuilder: (context, index) {
                  final challenge = challengeProvider.challenges[index];
                  return _buildChallengeCard(context, challenge);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF8FE3A2) : darkGreen;
    final secondaryColor =
        isDark
            ? Colors.white.withValues(alpha: 0.68)
            : darkGreen.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            context.tr('Weekly Challenges'),
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          Text(
            context.tr('Complete tasks to earn big points!'),
            style: TextStyle(color: secondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, Challenge challenge) {
    final isCompleted = challenge.isCompleted;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white;
    final accentColor = isDark ? const Color(0xFF8FE3A2) : darkGreen;
    final secondaryColor =
        isDark
            ? Colors.white.withValues(alpha: 0.68)
            : darkGreen.withValues(alpha: 0.65);
    final progressBg = isDark ? theme.colorScheme.surface : lightGreenBg;

    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: () => _openChallengeReport(context, challenge),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(challenge.icon, style: const TextStyle(fontSize: 35)),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(challenge.title),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(challenge.description),
                        style: TextStyle(color: secondaryColor, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.loc.daysLeft(challenge.daysLeft),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  context.loc.pointsWithPlus(challenge.points),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: challenge.progress,
                      backgroundColor: progressBg,
                      color: accentColor,
                      minHeight: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  context.loc.challengeProgress(
                    challenge.currentCount,
                    challenge.targetCount,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (isCompleted) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? accentColor.withValues(alpha: 0.12)
                          : lightGreenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.loc.challengeRewardUnlocked(challenge.points),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _openChallengeReport(context, challenge),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accentColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.loc.challengeButtonLabel(isCompleted),
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChallengeReport(BuildContext context, Challenge challenge) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ManualReportScreen(
              initialActivity: challenge.linkedActivityTitle,
            ),
      ),
    );

    showAppSnackBar(context, context.tr(challenge.linkedActivityTitle));
  }
}
