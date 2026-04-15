import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/session_provider.dart';
import '../../main_navigation_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final sessionProvider = context.read<SessionProvider>();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => sessionProvider.isAuthenticated
              ? MainNavigationScreen()
              : const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color greenBackground = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: greenBackground,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Think Green!',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
