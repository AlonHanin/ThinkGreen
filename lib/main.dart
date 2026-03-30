import 'package:flutter/material.dart';
// ייבוא של כל המסכים שיצרנו
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/security_pin_screen.dart';
import 'screens/reset_password_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // מעלים את הכיתוב DEBUG מהפינה
      title: 'Think Green',
      
      // הגדרת נושא כללי (אופציונלי)
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFE0E0E0), // הרקע האפור החיצוני
      ),

      // הנתיב שבו האפליקציה תתחיל (מסך הטעינה)
      initialRoute: '/',

      // רשימת כל הדרכים (Routes) באפליקציה
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/security_pin': (context) => const SecurityPinScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}
