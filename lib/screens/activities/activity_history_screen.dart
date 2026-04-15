import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../models/green_activity.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/activity_history_card.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  String _currentFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityProvider>();
    const Color darkGreen = Color(0xFF1B5E20);
    const Color lightGreenBg = Color(0xFFE8F5E9);

    final filteredActivities = provider.activities.where((activity) {
      switch (_currentFilter) {
        case 'Manual':
          return activity.source == ActivitySource.manual;
        case 'Approved':
          return activity.status == ActivityStatus.approved;
        case 'Pending':
          return activity.status == ActivityStatus.pending;
        default:
          return true;
      }
    }).toList();

    const filters = ['All', 'Manual', 'Approved', 'Pending'];

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
          context.tr('History'),
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
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: filters.map((filter) {
              final isSelected = _currentFilter == filter;
              return GestureDetector(
                onTap: () => setState(() => _currentFilter = filter),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? darkGreen : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: darkGreen.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    context.loc.sourceFilterLabel(filter),
                    style: TextStyle(
                      color: isSelected ? Colors.white : darkGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: filteredActivities.isEmpty
                ? Center(
                    child: Text(
                      context.tr('No activities found'),
                      style: TextStyle(color: darkGreen.withValues(alpha: 0.5)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: filteredActivities.length,
                    itemBuilder: (context, index) {
                      return ActivityHistoryCard(activity: filteredActivities[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
