import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_feedback.dart';

class SecurityPinScreen extends StatefulWidget {
  const SecurityPinScreen({super.key, this.isFromProfile = false});

  final bool isFromProfile;

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin(String email) async {
    final error = await context.read<SessionProvider>().verifySecurityPin(
          email: email,
          pin: _pinController.text,
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

    if (widget.isFromProfile) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushNamed(
      context,
      '/reset_password',
      arguments: {'email': email, 'pin': _pinController.text.trim()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionProvider>();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = (args?['email'] as String?) ?? sessionProvider.currentUser.email;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
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
                  context.tr('Security PIN'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.loc.securityPinSentTo(email),
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: context.tr('Enter PIN'),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1B5E20)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: sessionProvider.isBusy ? null : () => _verifyPin(email),
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
                            context.tr('Verify PIN'),
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
}
