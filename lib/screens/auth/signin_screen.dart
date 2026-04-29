import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../main_navigation_screen.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/google_button.dart';
import '../admin/admin_home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

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
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final sessionProvider = context.read<SessionProvider>();
    final error = await sessionProvider.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (error != null) {
      showAppSnackBar(
        context,
        context.tr(error),
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    showAppSnackBar(
      context,
      context.loc.welcomeBackFirstName(sessionProvider.currentUser.firstName),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => _destinationFor(sessionProvider)),
      (route) => false,
    );
  }

  Future<void> _handleGoogleSignIn() async {
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

    showAppSnackBar(
      context,
      context.loc.welcomeBackFirstName(sessionProvider.currentUser.firstName),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => _destinationFor(sessionProvider)),
      (route) => false,
    );
  }

  Widget _destinationFor(SessionProvider sessionProvider) {
    return sessionProvider.isAdmin
        ? const AdminHomeScreen()
        : const MainNavigationScreen();
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        isDark ? theme.colorScheme.surface : const Color(0xFFE8F5E9);
    final accentColor =
        isDark ? const Color(0xFF8FE3A2) : const Color(0xFF1B5E20);
    final mutedText =
        isDark ? Colors.white.withValues(alpha: 0.68) : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF1B5E20),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.tr('Welcome Back'),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.tr('Please enter your details'),
                    style: TextStyle(color: mutedText),
                  ),
                  const SizedBox(height: 40),
                  _buildInputLabel(context, context.tr('Email Address')),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'example@gmail.com',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildInputLabel(context, context.tr('Password')),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: '••••••••',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed:
                          () =>
                              Navigator.pushNamed(context, '/forgot_password'),
                      child: Text(
                        context.tr('Forgot Password?'),
                        style: TextStyle(color: accentColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildSignInButton(context, isBusy: sessionProvider.isBusy),
                  const SizedBox(height: 18),
                  Text(
                    context.tr('Or sign in with'),
                    style: TextStyle(color: mutedText, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  GoogleSignInButton(
                    onPressed:
                        sessionProvider.isBusy ? null : _handleGoogleSignIn,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(BuildContext context, String label) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF8FE3A2)
                  : const Color(0xFF1B5E20),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor =
        isDark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.white;
    final accentColor =
        isDark ? const Color(0xFF8FE3A2) : const Color(0xFF00695C);

    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        hintText: hintText,
        prefixIcon: Icon(icon, color: accentColor),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context, {required bool isBusy}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isBusy ? null : _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00695C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child:
            isBusy
                ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
                : Text(
                  context.tr('Sign In'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }
}
