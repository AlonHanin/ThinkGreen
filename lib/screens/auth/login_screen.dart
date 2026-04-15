import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_feedback.dart';
import '../admin/admin_home_screen.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _showAdminAuthDialog(BuildContext context) {
    final rootContext = context;
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    const Color darkGreen = Color(0xFF1B5E20);

    showDialog<void>(
      context: rootContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: darkGreen),
            const SizedBox(width: 10),
            Text(
              rootContext.tr('Admin Access'),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(rootContext.tr('Sign in with an admin account to continue.')),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: rootContext.tr('Email Address'),
                prefixIcon: const Icon(Icons.email_outlined, color: darkGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: rootContext.tr('Password'),
                prefixIcon: const Icon(Icons.lock_outline, color: darkGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              rootContext.tr('CANCEL'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: darkGreen),
            onPressed: () async {
              final sessionProvider = rootContext.read<SessionProvider>();

              final error = await sessionProvider.signIn(
                email: emailController.text.trim(),
                password: passwordController.text,
              );

              if (!rootContext.mounted) return;

              if (error != null) {
                showAppSnackBar(
                  rootContext,
                  rootContext.tr(error),
                  backgroundColor: Colors.red.shade700,
                );
                return;
              }

              if (!sessionProvider.isAdmin) {
                final message =
                    rootContext.tr('This account does not have admin access.');

                await sessionProvider.logout();

                if (!rootContext.mounted) return;

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }

                Navigator.of(rootContext).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );

                ScaffoldMessenger.of(rootContext).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                return;
              }

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }

              if (!rootContext.mounted) return;

              Navigator.of(rootContext).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const AdminHomeScreen(),
                ),
              );
            },
            child: Text(
              rootContext.tr('LOGIN'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkGreen = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
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
                  icon: Icon(
                    Icons.notifications_none,
                    color: Colors.grey[700],
                  ),
                  onPressed: () => showComingSoonSnackBar(
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
                          color: darkGreen,
                        ),
                      ),
                      Text(
                        context.tr('Be the future of our WORLD!'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildButton(
                        text: context.tr('Sign In'),
                        bgColor: const Color(0xFF00695C),
                        textColor: Colors.white,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignInScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildButton(
                        text: context.tr('Sign Up'),
                        bgColor: const Color(0xFFC8E6C9),
                        textColor: darkGreen,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/forgot_password'),
                        child: Text(
                          context.tr('Forgot Password?'),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      _buildButton(
                        text: context.tr('Admin Log In'),
                        bgColor: darkGreen,
                        textColor: Colors.white,
                        width: 180,
                        onPressed: () => _showAdminAuthDialog(context),
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