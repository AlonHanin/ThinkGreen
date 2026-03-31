import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/green_activity.dart';

class ActivityHistoryCard extends StatelessWidget {
  final GreenActivity activity;

  const ActivityHistoryCard({super.key, required this.activity});

  String _formatSource() {
    switch (activity.source) {
      case ActivitySource.manual:
        return 'Manual Report';
      case ActivitySource.strava:
        return 'From Strava';
      case ActivitySource.moovit:
        return 'From Moovit';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E2E2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatSource()} - ${DateFormat('dd/MM - HH:mm').format(activity.dateTime)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '+${activity.points} Points',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D18B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
