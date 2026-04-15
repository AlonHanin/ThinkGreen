import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/google_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  DateTime? _selectedDob;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _formatUiDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }

  String _formatApiDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$year-$month-$day';
  }

  Future<void> _pickDateOfBirth() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('en', 'GB'),
      helpText: context.tr('Select date of birth'),
      fieldHintText: 'DD/MM/YYYY',
      fieldLabelText: context.tr('Date Of Birth'),
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDob = pickedDate;
      _dobController.text = _formatUiDate(pickedDate);
    });
  }

  Future<void> _handleSignUp() async {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (fullName.length < 2) {
      showAppSnackBar(
        context,
        context.tr('Full name must contain at least 2 characters.'),
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    if (email.isEmpty) {
      showAppSnackBar(
        context,
        context.tr('Please enter a valid email address.'),
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    if (_selectedDob == null) {
      showAppSnackBar(
        context,
        context.tr('Please select your date of birth.'),
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    if (password.length < 6) {
      showAppSnackBar(
        context,
        context.tr('Password must contain at least 6 characters.'),
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    if (password != confirmPassword) {
      showAppSnackBar(
        context,
        context.tr('Passwords do not match.'),
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    final sessionProvider = context.read<SessionProvider>();

    final error = await sessionProvider.signUp(
      fullName: fullName,
      email: email,
      phone: phone,
      dateOfBirth: _formatApiDate(_selectedDob!),
      password: password,
      confirmPassword: confirmPassword,
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
      context.tr('Account created successfully.'),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
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
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF1B5E20),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      context.tr('Create Account'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      _buildInputLabel(context.tr('Full Name')),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _nameController,
                        context.tr('Full Name'),
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildInputLabel(context.tr('Email Address')),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _emailController,
                        'example@example.com',
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildInputLabel(context.tr('Phone Number')),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _phoneController,
                        '+972 5X XXX XXXX',
                        Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildInputLabel(context.tr('Date Of Birth')),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _dobController,
                        readOnly: true,
                        onTap: _pickDateOfBirth,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFD7EBD8),
                          hintText: 'DD/MM/YYYY',
                          prefixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF00695C),
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputLabel(context.tr('Password')),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _passwordController,
                        hint: context.tr('Password'),
                        isVisible: _isPasswordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInputLabel(context.tr('Confirm Password')),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _confirmController,
                        hint: context.tr('Confirm Password'),
                        isVisible: _isConfirmPasswordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: sessionProvider.isBusy ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00695C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: sessionProvider.isBusy
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  context.tr('Sign Up'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(context.tr('Already have an account? Log In')),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.tr('Or sign up with'),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      GoogleSignInButton(
                        onPressed: () => showComingSoonSnackBar(
                          context,
                          feature: 'Google sign up',
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

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B5E20),
        fontSize: 14,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFD7EBD8),
        hintText: hint,
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Color(0xFF00695C),
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}