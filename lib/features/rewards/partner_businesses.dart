import 'package:flutter/material.dart';

class PartnerBusinessesScreen extends StatelessWidget {
  const PartnerBusinessesScreen({super.key});

  static const Color primaryGreen = Color(0xFF00D285);
  static const Color lightBg = Color(0xFFE8F5E9);
  static const Color cardGrey = Color(0xFFD9D9D9);

  // רשימת עסקים לדוגמה
  final List<Map<String, String>> businesses = const [
    {
      'name': 'Eco Coffee Hub',
      'rewards': 'Discounts, Reusable Items',
      'location': 'Main St. 12',
    },
    {
      'name': 'Green Fashion',
      'rewards': 'Store Credit, Tote Bags',
      'location': 'Shopping Mall, Floor 1',
    },
    {
      'name': 'Nature Market',
      'rewards': 'Fresh Produce, Discounts',
      'location': 'North Ave. 45',
    },
    {
      'name': 'Bio Bakery',
      'rewards': 'Free Pastry, Coffee',
      'location': 'Central Square',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 10),
            const Text(
              "See Where You Can Use Your Rewards:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                itemCount: businesses.length,
                itemBuilder: (context, index) {
                  return _buildBusinessCard(
                    businesses[index]['name']!,
                    businesses[index]['rewards']!,
                    businesses[index]['location']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Partner\nBusinesses',
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

  Widget _buildBusinessCard(String name, String rewards, String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardGrey,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Business Name: $name",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 5),
          Text(
            "Available Rewards: $rewards",
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 5),
          Text(
            "Location: $location",
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // תפריט תחתון מלא (כמו שסידרנו קודם)
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
          _buildNavItem(Icons.card_giftcard, "Rewards", isSelected: true),
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
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
