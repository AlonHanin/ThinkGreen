import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_feedback.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkGreen = Color(0xFF1B5E20);
    final sessionProvider = context.watch<SessionProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: darkGreen, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('Settings'),
          style: GoogleFonts.outfit(
            color: darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle(context.tr('Notifications')),
          _buildSwitchTile(
            context.tr('Push Notifications'),
            context.tr('Get updates on challenges'),
            sessionProvider.notificationsEnabled,
            sessionProvider.setNotificationsEnabled,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context.tr('Appearance')),
          _buildSwitchTile(
            context.tr('Dark Mode'),
            context.tr('Change app theme'),
            sessionProvider.isDarkMode,
            sessionProvider.setDarkMode,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context.tr('Privacy')),
          _buildSwitchTile(
            context.tr('Location Services'),
            context.tr('Track green travels'),
            sessionProvider.locationServicesEnabled,
            sessionProvider.setLocationServicesEnabled,
          ),
          const SizedBox(height: 30),
          _buildSimpleTile(
            context,
            context.tr('Language'),
            context.loc.languageLabel(sessionProvider.locale),
            Icons.language,
            onTap: () => _showLanguageSheet(context, sessionProvider),
          ),
          _buildSimpleTile(
            context,
            context.tr('Terms of Service'),
            '',
            Icons.description_outlined,
            onTap: () => _showTermsDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 10, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1B5E20),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        value: value,
        activeThumbColor: const Color(0xFF1B5E20),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSimpleTile(
    BuildContext context,
    String title,
    String trailing,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1B5E20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing.isNotEmpty)
            Text(trailing, style: const TextStyle(color: Colors.grey)),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showLanguageSheet(
    BuildContext context,
    SessionProvider sessionProvider,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [const Locale('en'), const Locale('he')]
              .map(
                (locale) => ListTile(
                  title: Text(context.loc.languageLabel(locale)),
                  trailing: sessionProvider.locale.languageCode == locale.languageCode
                      ? const Icon(Icons.check, color: Color(0xFF1B5E20))
                      : null,
                  onTap: () {
                    sessionProvider.setLocale(locale);
                    Navigator.pop(bottomSheetContext);
                    showAppSnackBar(context, context.loc.languageUpdated(locale));
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('Terms of Service')),
        content: Text(
          context.isRtl
              ? 'Think Green היא כרגע אפליקציית אבטיפוס למכללה. בגרסת הייצור, אימות פעילויות, פרסים, שירותים מחוברים ואבטחת חשבון ינוהלו דרך שרת ומסד נתונים אמיתיים.'
              : 'Think Green is currently a college prototype. In the production version, activity validation, rewards, connected services and account security will be managed through a real backend and database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr('Close')),
          ),
        ],
      ),
    );
  }
}
