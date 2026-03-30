import 'package:flutter/material.dart';
import '../widgets/google_button.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0), // הרקע האפור החיצוני
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 9 / 19, // המסגרת הקבועה שלנו
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // הרקע הבהיר הפנימי
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // חלק עליון - כותרת ואייקון התראות
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B5E20)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Forgot Password',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_none, color: Color(0xFF1B5E20), size: 20),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reset Password?',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          const SizedBox(height: 40),

                          _buildInputLabel("Enter Email Address"),
                          const SizedBox(height: 8),
                          _buildTextField(_emailController, "example@example.com", Icons.email_outlined),

                          const SizedBox(height: 30),

                          // כפתור Next Step
                          _buildActionButton(
                            text: "Next Step",
                            onPressed: () {
                              Navigator.pushNamed(context, '/security_pin');
                              //צריך להוסיף שאם המייל שגוי זה לא יעבור הלאה
                            },
                          ),

                          const SizedBox(height: 40),

                      
                          
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // שומר על הכל צמוד במרכז
                              children: [
                                // שורה של "Don't have an account?"
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Don't have an account? ", style: TextStyle(fontSize: 12)),
                                    GestureDetector(
                                      onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
                                      child: const Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          color: Colors.lightBlue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 25), // רווח יפה בין החלקים
                                
                                // טקסט "Or sign up with"
                                Text(
                                  "Or sign up with",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // כפתור גוגל (כבר ממורכז בתוך ה-Column)
                                GoogleSignInButton(
                                  onPressed: () {
                                    print("Google Login Triggered!");
                                  },
                                ),
                              ],
                            ),
                          )
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

  // פונקציות עזר לשמירה על סגנון אחיד
  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), fontSize: 14),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFD7EBD8), // צבע שדה ירוק בהיר מאוד
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF00695C), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildActionButton({required String text, required VoidCallback onPressed}) {
    return Center(
      child: Container(
        width: 180,
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFF00695C),
          borderRadius: BorderRadius.circular(25),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFFD7EBD8),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          "Sign Up",
          style: TextStyle(color: const Color(0xFF1B5E20), fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, Color color, {bool isGoogle = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black54),
      ),
      child: Icon(icon, color: color, size: isGoogle ? 35 : 25),
    );
  }
}