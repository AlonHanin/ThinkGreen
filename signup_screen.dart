import 'package:flutter/material.dart';
import '../widgets/google_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // בקרים לשליטה בטקסט
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0), // הרקע האפור של ה"שולחן"
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 9 / 19, // המסגרת ששומרת על פרופורציה של טלפון
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // הרקע הבהיר של האפליקציה
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // שורת כפתור חזרה וכותרת
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B5E20)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // גוף הטופס עם גלילה
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        children: [
                          _buildInputLabel("Full Name"),
                          const SizedBox(height: 8),
                          _buildTextField(_nameController, "example@example.com", Icons.person_outline),
                          
                          const SizedBox(height: 15),
                          _buildInputLabel("Email"),
                          const SizedBox(height: 8),
                          _buildTextField(_emailController, "example@example.com", Icons.email_outlined),
                          
                          const SizedBox(height: 15),
                          _buildInputLabel("Mobile Number"),
                          const SizedBox(height: 8),
                          _buildTextField(_phoneController, "+ 123 456 789", Icons.phone_android_outlined),
                          
                          const SizedBox(height: 15),
                          _buildInputLabel("Date Of Birth"),
                          const SizedBox(height: 8),
                          _buildTextField(_dobController, "DD / MM / YYYY", Icons.calendar_today_outlined),
                          
                          const SizedBox(height: 15),
                          _buildInputLabel("Password"),
                          const SizedBox(height: 8),
                          _buildTextField(
                            _passwordController, 
                            "••••••••", 
                            Icons.lock_outline, 
                            isPassword: true
                          ),
                          
                          const SizedBox(height: 15),
                          _buildInputLabel("Confirm Password"),
                          const SizedBox(height: 8),
                          _buildTextField(
                            _confirmController, 
                            "••••••••", 
                            Icons.lock_reset_outlined, 
                            isPassword: true
                          ),

                          const SizedBox(height: 25),
                          
                          // כפתור הרשמה
                          _buildSignUpButton(),
                          
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/signin'),
                            child: const Text(
                              "Already have an account? Log In",
                              style: TextStyle(color: Color(0xFF00695C), fontSize: 12),
                            ),
                          ),
                          
                          Text(
                            "Or sign up with",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // פונקציות עזר זהות לסגנון של ה-SignIn ששלחת
  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF00695C), size: 20),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, size: 20),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          print("Registering: ${_emailController.text}");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00695C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text(
          'Sign Up',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}