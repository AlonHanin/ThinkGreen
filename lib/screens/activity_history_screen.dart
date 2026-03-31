import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/activity_provider.dart';
import '../models/green_activity.dart';
import '../widgets/activity_history_card.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  String _currentFilter = 'All';

  final List<String> _filters = ['All', 'Manual'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActivityProvider>(context);

    // Filter activities
    final filteredActivities = provider.activities.where((activity) {
      if (_currentFilter == 'All') return true;
      if (_currentFilter == 'Manual' && activity.source == ActivitySource.manual) return true;
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF00D18B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 38,
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    )
                  ],
                ),
                children: const [
                  TextSpan(text: 'Activity\n', style: TextStyle(fontWeight: FontWeight.w300)),
                  TextSpan(text: 'History', style: TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            // Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('[ ', style: TextStyle(color: Colors.white, fontSize: 16)),
                ..._filters.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final filter = entry.value;
                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentFilter = filter;
                          });
                        },
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: _currentFilter == filter ? Colors.white : Colors.white70,
                            fontWeight: _currentFilter == filter ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (idx < _filters.length - 1)
                        const Text(' | ', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  );
                }),
                const Text(' ]', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),
            
            // List
            Expanded(
              child: ListView.builder(
                itemCount: filteredActivities.length,
                itemBuilder: (context, index) {
                  return ActivityHistoryCard(
                    activity: filteredActivities[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
