import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main_navigation_screen.dart';
import '../providers/session_provider.dart';
import '../screens/auth/login_screen.dart';

bool ensureAdminAccess(BuildContext context) {
  final sessionProvider = context.read<SessionProvider>();
  if (sessionProvider.isAuthenticated && sessionProvider.isAdmin) {
    return true;
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder:
            (_) =>
                sessionProvider.isAuthenticated
                    ? const MainNavigationScreen()
                    : const LoginScreen(),
      ),
      (route) => false,
    );
  });

  return false;
}
