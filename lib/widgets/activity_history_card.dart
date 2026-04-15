import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n_app_localizations.dart';
import '../models/green_activity.dart';

class ActivityHistoryCard extends StatelessWidget {
  final GreenActivity activity;

  const ActivityHistoryCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    const Color darkGreen = Color(0xFF1B5E20);

    final statusLabel = switch (activity.status) {
      ActivityStatus.approved => context.loc.pointsShort(activity.points),
      ActivityStatus.pending => context.tr('Pending'),
      ActivityStatus.rejected => context.tr('Rejected'),
    };

    final statusColor = switch (activity.status) {
      ActivityStatus.approved => darkGreen,
      ActivityStatus.pending => Colors.orange,
      ActivityStatus.rejected => Colors.red,
    };

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: darkGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    switch (activity.source) {
                      ActivitySource.manual => Icons.edit_note,
                      ActivitySource.strava => Icons.directions_run,
                      ActivitySource.moovit => Icons.directions_bus,
                    },
                    color: darkGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(activity.title),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy | HH:mm').format(activity.dateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: darkGreen.withValues(alpha: 0.5),
                        ),
                      ),
                      if (activity.userName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          activity.userName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: darkGreen.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
