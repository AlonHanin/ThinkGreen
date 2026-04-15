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
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: Consumer<ChallengeProvider>(
            builder: (context, challengeProvider, _) {
              if (challengeProvider.isLoading && challengeProvider.challenges.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (challengeProvider.challenges.isEmpty) {
                return Center(child: Text(context.tr('No challenges available yet.')));
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            context.tr('Weekly Challenges'),
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          Text(
            context.tr('Complete tasks to earn big points!'),
            style: TextStyle(color: darkGreen.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, Challenge challenge) {
    final isCompleted = challenge.isCompleted;

    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: () => _openChallengeReport(context, challenge),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(challenge.description),
                        style: TextStyle(
                          color: darkGreen.withValues(alpha: 0.65),
                          fontSize: 12,
                        ),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: darkGreen,
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
                      backgroundColor: lightGreenBg,
                      color: darkGreen,
                      minHeight: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  context.loc.challengeProgress(challenge.currentCount, challenge.targetCount),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: lightGreenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.loc.challengeRewardUnlocked(challenge.points),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: darkGreen,
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
                  side: const BorderSide(color: darkGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.loc.challengeButtonLabel(isCompleted),
                  style: const TextStyle(
                    color: darkGreen,
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
        builder: (_) => ManualReportScreen(initialActivity: challenge.linkedActivityTitle),
      ),
    );

    showAppSnackBar(
      context,
      context.tr(challenge.linkedActivityTitle),
    );
  }
}
