import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n_app_localizations.dart';
import '../../utils/app_feedback.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkGreen = Color(0xFF1B5E20);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        isDark ? theme.colorScheme.surface : const Color(0xFFE8F5E9);
    final accentColor = isDark ? const Color(0xFF8FE3A2) : darkGreen;
    final secondaryText =
        isDark ? Colors.white.withValues(alpha: 0.68) : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              PositionedDirectional(
                top: 20,
                end: 20,
                child: IconButton(
                  icon: Icon(Icons.notifications_none, color: secondaryText),
                  onPressed:
                      () => showComingSoonSnackBar(
                        context,
                        feature: 'Notifications',
                      ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr('Think Green'),
                        style: GoogleFonts.outfit(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      Text(
                        context.tr('Be the future of our WORLD!'),
                        style: TextStyle(fontSize: 12, color: secondaryText),
                      ),
                      const SizedBox(height: 40),
                      _buildButton(
                        text: context.tr('Sign In'),
                        bgColor: const Color(0xFF00695C),
                        textColor: Colors.white,
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignInScreen(),
                              ),
                            ),
                      ),
                      const SizedBox(height: 15),
                      _buildButton(
                        text: context.tr('Sign Up'),
                        bgColor:
                            isDark
                                ? theme.colorScheme.surfaceContainerHighest
                                : const Color(0xFFC8E6C9),
                        textColor: accentColor,
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            ),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.pushNamed(
                              context,
                              '/forgot_password',
                            ),
                        child: Text(
                          context.tr('Forgot Password?'),
                          style: TextStyle(
                            color:
                                isDark
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
