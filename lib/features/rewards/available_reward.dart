import 'package:flutter/material.dart';

class AvailableRewardsScreen extends StatelessWidget {
  const AvailableRewardsScreen({super.key});

  static const Color primaryGreen = Color(0xFF00D285);
  static const Color lightBg = Color(0xFFE8F5E9);
  static const Color cardGrey = Color(0xFFD9D9D9);

  // רשימת נתונים לדוגמה (בהמשך זה יכול להגיע ממסד נתונים)
  final List<Map<String, String>> rewards = const [
    {'title': 'Free Coffee (Reusable Cup Only)', 'cost': '250 Points'},
    {'title': '10% Discount At Partner Store', 'cost': '300 Points'},
    {'title': 'Bus Ticket Credit', 'cost': '200 Points'},
    {'title': 'Tree Planting Donation', 'cost': '300 Points'},
    {'title': 'Free Drink Upgrade', 'cost': '200 Points'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header עם כפתור חזור
            _buildHeader(context),

            const SizedBox(height: 10),
            const Text(
              "Choose A Reward And Redeem Your Points:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // רשימת הפרסים
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                itemCount: rewards.length,
                itemBuilder: (context, index) {
                  return _buildRewardCard(
                    rewards[index]['title']!,
                    rewards[index]['cost']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation (העתקנו מהעמוד הקודם לשמירה על רצף)
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
            onPressed: () => Navigator.pop(context), // חוזר לעמוד הקודם
          ),
          const Text(
            'Available\nRewards',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(String title, String cost) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardGrey,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.blue,
          width: 1,
        ), // המסגרת הכחולה שסימנת בתמונה
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Cost: $cost",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF00), // ירוק זוהר לכפתור
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  "Redeem",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 80,
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, "Home"),
          _buildNavItem(Icons.show_chart, "Activities"),
          _buildNavItem(
            Icons.card_giftcard,
            "Rewards",
            isSelected: true,
          ), // מודגש
          _buildNavItem(Icons.layers_outlined, "Challenges"),
          _buildNavItem(Icons.person_outline, "Profile"),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.black54,
            size: 26,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? primaryGreen : Colors.black54,
          ),
        ),
      ],
    );
  }
}
