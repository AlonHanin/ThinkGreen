//זהווידג'ט של כפתור פעולה עם כותרת ותיאור, שמאפשר למשתמש ללחוץ עליו כדי לבצע פעולה מסוימת. הכפתור מעוצב עם רקע אפור, פינות מעוגלות וצל כדי להדגיש אותו על המסך. הכותרת מוצגת בגופן מודגש, והטקסט המשני מוצג בגופן קטן יותר עם צבע כהה יותר. כאשר המשתמש לוחץ על הכפתור, מתבצעת הפעולה שהוגדרה ב-`onTap`.

import 'package:flutter/material.dart';

class ActionButtonWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ActionButtonWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark
            ? theme.colorScheme.surfaceContainerHighest
            : const Color(0xFFE2E2E2);
    final titleColor = isDark ? theme.colorScheme.onSurface : Colors.black87;
    final subtitleColor =
        isDark ? Colors.white.withValues(alpha: 0.68) : Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ).copyWith(color: titleColor),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ).copyWith(color: subtitleColor),
                    ),
                  ),
                  Icon(Icons.arrow_forward, size: 20, color: titleColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
