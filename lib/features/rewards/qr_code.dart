import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // יבוא החבילה של ה-QR

class QRCodeScreen extends StatelessWidget {
  const QRCodeScreen({super.key});

  static const Color primaryGreen = Color(0xFF00D285);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            // כותרת עם כפתור חזור
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Use Your\nReward!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // כדי לאזן את כפתור החזור
                ],
              ),
            ),

            const SizedBox(height: 50),

            const Text(
              "Show This QR Code To The Business:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 30),

            // כרטיס ה-QR הלבן
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: QrImageView(
                data:
                    'https://www.eco-recycling-app.com/reward/12345', // הנתונים שייצרו את ה-QR (בהמשך זה יהיה המזהה הייחודי של הפרס)
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),

            const Spacer(), // דוחף את הטקסט למטה

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Text(
                "Keep this screen open until the business scans your code. Enjoy your reward!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
