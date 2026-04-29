import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_feedback.dart';
import '../auth/forgot_password_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkGreen = Color(0xFF1B5E20);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF8FE3A2) : darkGreen;
    final user = context.watch<SessionProvider>().currentUser;
    final hasAvatar = user.avatarUrl.trim().isNotEmpty;

    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(color: darkGreen),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 20,
                child: Text(
                  context.tr('Profile'),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: const Color(0xFFE8F5E9),
                        backgroundImage:
                            hasAvatar ? NetworkImage(user.avatarUrl) : null,
                        child:
                            hasAvatar
                                ? null
                                : Text(
                                  user.initials,
                                  style: GoogleFonts.outfit(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: darkGreen,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.fullName,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      '${context.isRtl ? 'מזהה' : 'ID'}: ${user.id}',
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 70),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            children: [
              _buildItem(
                context,
                Icons.person_outline,
                context.tr('Edit Profile'),
                const EditProfileScreen(),
                const Color(0xFFE3F2FD),
                Colors.blue,
                isDark: isDark,
              ),
              _buildItem(
                context,
                Icons.security_outlined,
                context.tr('Security'),
                const ForgotPasswordScreen(),
                const Color(0xFFF3E5F5),
                Colors.purple,
                isDark: isDark,
              ),
              _buildItem(
                context,
                Icons.settings_outlined,
                context.tr('Settings'),
                const SettingsScreen(),
                const Color(0xFFE8F5E9),
                Colors.green,
                isDark: isDark,
              ),
              _buildItem(
                context,
                Icons.help_outline,
                context.tr('Help'),
                null,
                const Color(0xFFFFF3E0),
                Colors.orange,
                isDark: isDark,
              ),
              _buildItem(
                context,
                Icons.logout,
                context.tr('Logout'),
                null,
                const Color(0xFFFFEBEE),
                Colors.red,
                isLogout: true,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget? target,
    Color bgColor,
    Color iconColor, {
    bool isLogout = false,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            isDark
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: () {
          if (isLogout) {
            context.read<SessionProvider>().logout();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
            return;
          }

          if (target != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => target));
            return;
          }

          showComingSoonSnackBar(context, feature: title);
        },
      ),
    );
  }
}
