import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_feedback.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = args?['email'] as String?;
    final pin = args?['pin'] as String?;

    if (email == null || pin == null) {
      showAppSnackBar(
        context,
        context.tr('Password reset session expired. Start again from Forgot Password.'),
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    final error = await context.read<SessionProvider>().resetPassword(
          email: email,
          pin: pin,
          newPassword: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

    if (!mounted) return;

    if (error != null) {
      showAppSnackBar(context, context.tr(error), backgroundColor: Colors.red.shade700);
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('Password Updated')),
        content: Text(context.tr('Your password was changed successfully. Please sign in with your new password.')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: Text(context.tr('Back to Login')),
          ),
        ],
      ),
    );
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B5E20)),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
                Text(
                  context.tr('Create New Password'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.tr('Choose a strong password with at least 6 characters.'),
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 30),
                _buildField(controller: _passwordController, label: context.tr('New Password')),
                const SizedBox(height: 16),
                _buildField(controller: _confirmPasswordController, label: context.tr('Confirm Password')),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: sessionProvider.isBusy ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00695C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: sessionProvider.isBusy
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text(
                            context.tr('Change Password'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
