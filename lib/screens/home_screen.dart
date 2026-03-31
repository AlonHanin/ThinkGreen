import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'manual_report_screen.dart';
import 'activity_history_screen.dart';
import '../widgets/action_button_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D18B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Usually to go back, but this is home. Left as per UI if needed
          },
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
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 42,
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
                  TextSpan(text: 'Green\n', style: TextStyle(fontWeight: FontWeight.w300)),
                  TextSpan(text: 'Activities', style: TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Manage & Track\nYour Green Actions',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 48),
            ActionButtonWidget(
              title: 'Report Green Activities',
              subtitle: 'Add Your Eco-Friendly Actions Manually',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManualReportScreen()),
                );
              },
            ),
            ActionButtonWidget(
              title: 'Green Activity History',
              subtitle: 'See All Your Tracked Green Activities',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActivityHistoryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
