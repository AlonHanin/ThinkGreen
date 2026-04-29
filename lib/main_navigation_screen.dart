import 'package:flutter/material.dart';

import 'l10n_app_localizations.dart';
import 'screens/activities/activities_menu_screen.dart';
import 'screens/challenges/challenges_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/rewards/redeem_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  static MainNavigationScreenState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<MainNavigationScreenState>();
  }

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void updateIndex(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _screens = [
    const HomeScreen(),
    const ActivitiesMenuScreen(),
    const RedeemScreen(),
    const ChallengesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color darkGreen = Color(0xFF1B5E20);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedColor = isDark ? const Color(0xFF8FE3A2) : darkGreen;

    return Scaffold(
      backgroundColor:
          isDark ? theme.colorScheme.surface : const Color(0xFFE8F5E9),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: updateIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor:
            isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
        selectedItemColor: selectedColor,
        unselectedItemColor:
            isDark ? Colors.white.withValues(alpha: 0.62) : Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: context.tr('Home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart),
            label: context.tr('Activities'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.card_giftcard),
            label: context.tr('Rewards'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.layers),
            label: context.tr('Challenges'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: context.tr('Profile'),
          ),
        ],
      ),
    );
  }
}
