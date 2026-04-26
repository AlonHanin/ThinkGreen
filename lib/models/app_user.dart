import '../services/api/api_payload_utils.dart';

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;
  final String password;
  final String avatarUrl;
  final String role;
  final bool notificationsEnabled;
  final bool isDarkMode;
  final bool locationServicesEnabled;
  final String preferredLanguage;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    this.dateOfBirth,
    this.avatarUrl = '',
    this.role = 'user',
    this.notificationsEnabled = true,
    this.isDarkMode = false,
    this.locationServicesEnabled = true,
    this.preferredLanguage = 'en',
  });

  factory AppUser.empty() => const AppUser(
        id: '',
        fullName: '',
        email: '',
        phone: '',
        password: '',
      );

  factory AppUser.fromApi(dynamic source) {
    final root = asMap(source) ?? const <String, dynamic>{};
    final profile = firstNestedMap(root, const ['profile', 'user', 'account']) ?? root;

    return AppUser(
      id: firstString(profile, const ['id', 'user_id', 'public_id']) ?? '',
      fullName: firstString(profile, const ['full_name', 'fullName', 'name']) ?? '',
      email: firstString(profile, const ['email']) ?? '',
      phone: firstString(profile, const ['phone', 'mobile', 'phone_number']) ?? '',
      password: firstString(profile, const ['password']) ?? '',
      dateOfBirth: firstDateTime(profile, const ['date_of_birth', 'dateOfBirth', 'dob']),
      avatarUrl: firstString(profile, const ['avatar_url', 'avatarUrl', 'image_url', 'photo_url']) ?? '',
      role: firstString(profile, const ['role', 'user_role']) ?? 'user',
      notificationsEnabled:
          firstBool(profile, const ['notifications_enabled', 'notificationsEnabled']) ?? true,
      isDarkMode: firstBool(profile, const ['dark_mode', 'darkMode']) ?? false,
      locationServicesEnabled:
          firstBool(profile, const ['location_services_enabled', 'locationServicesEnabled']) ?? true,
      preferredLanguage:
          firstString(profile, const ['preferred_language', 'preferredLanguage', 'locale']) ?? 'en',
    );
  }

  String get firstName {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(RegExp(r'\s+'));
    return parts.first;
  }

  String get initials {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '?';

    final parts = trimmed.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  bool get isAdmin => role.toLowerCase() == 'admin';

  AppUser copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? password,
    String? avatarUrl,
    String? role,
    bool? notificationsEnabled,
    bool? isDarkMode,
    bool? locationServicesEnabled,
    String? preferredLanguage,
  }) {
    return AppUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      password: password ?? this.password,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      locationServicesEnabled: locationServicesEnabled ?? this.locationServicesEnabled,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }
}
