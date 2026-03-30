import 'package:flutter/material.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0), // הרקע שמאחורי ה"טלפון"
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 9 / 19,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // הרקע הבהיר בתוך המסך
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // אייקון התראות
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Icon(Icons.notifications_none, color: Colors.grey[700]),
                  ),
                  
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Think Green',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          Text(
                            'Be the feature of our WORLD!',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 40),
                          
                          // כפתור התחברות
                          _buildButton(
                            text: 'Sign In',
                            bgColor: const Color(0xFF00695C),
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignInScreen()),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // כפתור הרשמה שמעביר למסך SignUp
                          _buildButton(
                            text: 'Sign Up',
                            bgColor: const Color(0xFFC8E6C9),
                            textColor: const Color(0xFF1B5E20),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignUpScreen()),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // שכחת סיסמה
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgot_password');
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.grey[700], fontSize: 12),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // כפתור אדמין
                          _buildButton(
                            text: 'Admin Log In',
                            bgColor: const Color(0xFF00695C),
                            textColor: Colors.white,
                            width: 200,
                            onPressed: () {
                              print("Admin Log In Clicked");
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // פונקציית עזר משופרת ליצירת כפתורים
  Widget _buildButton({
    required String text,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onPressed,
    double? width,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}