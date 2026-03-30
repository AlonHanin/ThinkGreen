import 'package:flutter/material.dart';
import '../widgets/google_button.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // בקרים לשליטה בטקסט שהמשתמש מקליד
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 9 / 19,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: SingleChildScrollView( // מאפשר גלילה כשהמקלדת נפתחת
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // כפתור חזרה
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B5E20)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please enter your details',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 40),

                      // שדה אימייל
                      _buildInputLabel("Email Address"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hintText: "example@gmail.com",
                        icon: Icons.email_outlined,
                      ),
                      
                      const SizedBox(height: 20),

                      // שדה סיסמה
                      _buildInputLabel("Password"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: "••••••••",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
                          child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFF00695C))),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // כפתור כניסה
                      _buildSignInButton(),

                      Text(
                            "Or sign in with",
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          // כפתור הרשמה google
                          GoogleSignInButton(
                            onPressed: () {
                              print("Google Login Triggered!");
                              // כאן יבוא ה-API בעתיד
                            },
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // פונקציית עזר לכותרת מעל שדה הקלט
  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
      ),
    );
  }

  // פונקציית עזר לבניית שדות הקלט
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        prefixIcon: Icon(icon, color: const Color(0xFF00695C)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          print("Logging in with: ${_emailController.text}");
          // כאן יבוא החיבור ל-PHP ב-cPanel
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00695C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text(
          'Sign In',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}