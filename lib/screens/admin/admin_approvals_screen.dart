import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../models/green_activity.dart';
import '../../providers/activity_provider.dart';

class AdminApprovalsScreen extends StatefulWidget {
  const AdminApprovalsScreen({super.key});

  @override
  State<AdminApprovalsScreen> createState() => _AdminApprovalsScreenState();
}

class _AdminApprovalsScreenState extends State<AdminApprovalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadPendingActivities();
    });
  }

  Future<void> _handleReview(
    BuildContext context,
    GreenActivity activity, {
    required bool approve,
  }) async {
    final provider = context.read<ActivityProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final successMessage = context.tr(
      approve ? 'Activity approved and points granted.' : 'Activity rejected.',
    );

    final error = approve
        ? await provider.approveActivity(activity.id)
        : await provider.rejectActivity(activity.id);

    if (!mounted) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(error ?? successMessage),
        backgroundColor: error != null ? Colors.red.shade700 : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1B5E20);
    const lightGreenBg = Color(0xFFE8F5E9);
    final activityProvider = context.watch<ActivityProvider>();
    final pendingActivities = activityProvider.pendingActivities;

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
          context.tr('Review Requests'),
          style: GoogleFonts.outfit(
            color: darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: activityProvider.isLoading && pendingActivities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : pendingActivities.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () async {
                    await context.read<ActivityProvider>().loadPendingActivities();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: pendingActivities.length,
                    itemBuilder: (context, index) => _buildReviewCard(
                      context,
                      pendingActivities[index],
                      isReviewing: activityProvider.isReviewing,
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_outlined, size: 54, color: Colors.green.shade700),
            const SizedBox(height: 14),
            Text(
              context.tr('No pending approvals right now.'),
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    GreenActivity activity, {
    required bool isReviewing,
  }) {
    const darkGreen = Color(0xFF1B5E20);
    const lightGreenBg = Color(0xFFE8F5E9);
    final hasImageBytes = activity.imageBytes != null && activity.imageBytes!.isNotEmpty;
    final hasImageUrl = activity.imageUrl != null && activity.imageUrl!.trim().isNotEmpty;
    final imageUrl = hasImageUrl ? activity.imageUrl!.trim() : null;
    final safeImageUrl = imageUrl ?? '';
    final hasLocalImage = imageUrl != null && !kIsWeb && File(safeImageUrl).existsSync();
    final hasRemoteImage = imageUrl != null && safeImageUrl.startsWith('http');
    final imageExists = hasImageBytes || hasLocalImage || hasRemoteImage;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: lightGreenBg,
              child: Text(
                activity.userName?.isNotEmpty == true
                    ? activity.userName!.trim()[0].toUpperCase()
                    : '?',
                style: const TextStyle(color: darkGreen, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              activity.userName?.isNotEmpty == true ? activity.userName! : context.tr('Unknown User'),
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: darkGreen),
            ),
            subtitle: Text(activity.title),
            trailing: Text(
              '+${activity.points}',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Submitted: ${DateFormat('dd/MM/yyyy • HH:mm').format(activity.dateTime)}',
              style: TextStyle(
                color: darkGreen.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (imageExists) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: hasImageBytes
                    ? Image.memory(
                        activity.imageBytes!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : hasLocalImage
                        ? Image.file(
                            File(safeImageUrl),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            safeImageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isReviewing ? null : () => _handleReview(context, activity, approve: false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      context.tr('Reject'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isReviewing ? null : () => _handleReview(context, activity, approve: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isReviewing
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                          )
                        : Text(
                            context.tr('Approve'),
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
