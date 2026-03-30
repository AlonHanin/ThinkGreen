import 'package:flutter/material.dart';

class SecurityPinScreen extends StatefulWidget {
  const SecurityPinScreen({super.key});

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  // רשימה של בקרים עבור 6 העיגולים של הקוד
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color greenBackground = Color(0xFF1B5E20);

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
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Security Pin',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: greenBackground),
                  ),
                  const SizedBox(height: 60),
                  const Text(
                    'Enter Security Pin',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: greenBackground),
                  ),
                  const SizedBox(height: 30),
                  
                  // שורת עיגולי הקוד
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) => _buildPinBox(index)),
                  ),

                  const SizedBox(height: 50),

                  // כפתור Accept
                  SizedBox(
                    width: 150,
                    height: 45,
                    child: ElevatedButton(
                      // בתוך SecurityPinScreen
                      onPressed: () {
                        // TODO: כאן צריך להוסיף בדיקה מול ה-PHP וה-Database
                        // צריך לשלוח את הקוד שהמשתמש הזין ולוודא שהוא תואם למה שנשלח במייל
                        // כרגע זה עובר הלאה אוטומטית לצורך הבדיקה העיצובית:
                        
                        Navigator.pushNamed(context, '/reset_password');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Accept', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => print("Resend Code"),
                    child: const Text('Send Again', style: TextStyle(color: greenBackground, fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ווידג'ט לתיבת קלט של ספרה אחת (בעיגול)
  Widget _buildPinBox(int index) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1B5E20), width: 2),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
        decoration: const InputDecoration(counterText: "", border: InputBorder.none),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus(); // עובר אוטומטית לעיגול הבא
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus(); // חוזר אחורה במחיקה
          }
        },
      ),
    );
  }
}