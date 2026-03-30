import 'package:flutter/material.dart';
import 'dart:async'; // דרוש עבור ה-Timer
import 'login_screen.dart'; // נייבא את מסך הלוגין כדי לעבור אליו

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // יצירת טיימר שיעבור מסך אחרי 3 שניות
    Timer(const Duration(seconds: 3), () {
      // ניווט למסך ה-Login והסרת מסך הטעינה מההיסטוריה (כדי שאי אפשר יהיה לחזור אליו עם כפתור 'אחורה')
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // השתמשתי בצבע הירוק מהלוגו ומהעיצובים שלך
    const Color greenBackground = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: greenBackground, // צבע רקע ירוק מלא
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // טקסט לבן גדול במרכז
            const Text(
              'Think Green!',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white, // צבע טקסט לבן
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 30), // מרווח קטן
            // אינדיקטור טעינה לבן קטן מתחת לטקסט
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}