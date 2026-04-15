import 'package:flutter/material.dart';

import '../l10n_app_localizations.dart';

const Color appDarkGreen = Color(0xFF1B5E20);

void showAppSnackBar(
  BuildContext context,
  String message, {
  Color backgroundColor = appDarkGreen,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

void showComingSoonSnackBar(BuildContext context, {String? feature}) {
  showAppSnackBar(context, context.loc.comingSoon(feature));
}
