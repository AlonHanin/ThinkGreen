import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/google_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentEmail = context.read<SessionProvider>().currentUser.email;
    if (_emailController.text.isEmpty && currentEmail.isNotEmpty) {
      _emailController.text = currentEmail;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _goToSecurityPin() async {
    final email = _emailController.text.trim();
    final sessionProvider = context.read<SessionProvider>();
    final error = await sessionProvider.requestResetPin(email);

    if (!mounted) return;

    if (error != null) {
      showAppSnackBar(
        context,
        context.tr(error),
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/security_pin',
      arguments: {'email': email, 'fromProfile': false},
    );
  }

  Future<void> _handleGoogleSignUp() async {
    final sessionProvider = context.read<SessionProvider>();
    final error = await sessionProvider.signInWithGoogle();

    if (!mounted) return;

    if (error != null) {
      showAppSnackBar(
        context,
        context.tr(error),
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    showAppSnackBar(context, context.tr('Account created successfully.'));

    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF1B5E20),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      context.tr('Forgot Password'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Color(0xFF1B5E20),
                      ),
                      onPressed:
                          () => showComingSoonSnackBar(
                            context,
                            feature: 'Notifications',
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('Reset Password?'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.tr(
                          'Enter the email linked to your Think Green account. We will verify you with a short security PIN before letting you create a new password.',
                        ),
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 40),
                      _buildInputLabel(context.tr('Enter Email Address')),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _emailController,
                        'example@example.com',
                        Icons.email_outlined,
                      ),
                      const SizedBox(height: 30),
                      _buildActionButton(
                        text: context.tr('Next Step'),
                        isBusy: sessionProvider.isBusy,
                        onPressed: _goToSecurityPin,
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  context.tr("Don't have an account? "),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                GestureDetector(
                                  onTap:
                                      () => Navigator.pushReplacementNamed(
                                        context,
                                        '/signup',
                                      ),
                                  child: Text(
                                    context.tr('Sign Up'),
                                    style: const TextStyle(
                                      color: Colors.lightBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Text(
                              context.tr('Or sign up with'),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GoogleSignInButton(
                              onPressed:
                                  sessionProvider.isBusy
                                      ? null
                                      : _handleGoogleSignUp,
                            ),
                          ],
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

  Widget _buildInputLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF1B5E20),
      fontSize: 14,
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFD7EBD8),
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

  Widget _buildActionButton({
    required String text,
    required bool isBusy,
    required Future<void> Function() onPressed,
  }) {
    return Center(
      child: SizedBox(
        width: 180,
        height: 45,
        child: ElevatedButton(
          onPressed: isBusy ? null : () => onPressed(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00695C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child:
              isBusy
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                  : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
    );
  }
}
